import 'dart:io';

import 'package:flutter/material.dart';
import 'package:letstry/cache.dart';
import 'package:letstry/models/animations.dart';
import 'package:letstry/models/frame.dart';
import 'package:letstry/services/ffmpeg.dart';
import 'package:letstry/utils/screens.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ProjectProvider with ChangeNotifier {
  List<Animations> animations = [];
  Size defaultFramesSize = Size(256, 256);
  List<String> toNotify = [];
  int selectedAnimationIndex = 0;

  Animations get currentAnimation => animations[selectedAnimationIndex];

  void setFramesSize(Size size) {
    defaultFramesSize = size;
    notify([W.editorSidebar]);
  }

  void notify(List<String> texts) {
    toNotify.addAll(texts);
    notifyListeners();
  }

  void setSelectedAnimationIndex(int index) {
    selectedAnimationIndex = index;
    notify([W.editorSidebar, W.editorPreview, W.editorcontrolBar]);
  }

  void toggleLoop() {
    currentAnimation.loop = !currentAnimation.loop;
    notify([W.editorcontrolBar, W.editorPreview]);
  }

  void toggleAutoPlay() {
    currentAnimation.autoPlay = !currentAnimation.autoPlay;
    notify([W.editorcontrolBar, W.editorPreview]);
  }

  void addNewAnimation() {
    animations.add(
      Animations(
        id: Uuid().v4(),

        name: "New Animation",
        frames: [],
        fps: 24,
        loop: true,
        autoPlay: true,
        reverse: false,
      ),
    );
    notify([W.editorSidebar]);
  }

  ProjectProvider() {
    animations.add(
      Animations(
        id: Uuid().v4(),
        name: 'default',
        frames: [],
        fps: 24,
        loop: true,
        autoPlay: true,
        reverse: false,
      ),
    );
  }

  void addNewFrame(String input) async {
    final currentAnimationOutputPath =
        "${Cache.tempPath!}/${currentAnimation.id}";

    if (!(await Directory(currentAnimationOutputPath).exists())) {
      await Directory(currentAnimationOutputPath).create();
    }

    final outputPath =
        "$currentAnimationOutputPath/${path.basenameWithoutExtension(path.basename(input))}.png";

    await FFmpegCommands.resizeImage(
      input,
      outputPath,
      defaultFramesSize,
    );

    final frame = Frame(
      id: Uuid().v4(),
      name: path.basename(input),
      size: defaultFramesSize,
      imagePath: outputPath,
    );

    currentAnimation.frames.add(frame);
    notify([W.editorFramesView, W.editorPreview]);
  }
}
