import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:letstry/cache.dart';
import 'package:letstry/models/animations.dart';
import 'package:letstry/models/frame.dart';
import 'package:letstry/models/spritesheet_slice.dart';
import 'package:letstry/services/ffmpeg.dart';
import 'package:letstry/utils/screens.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ProjectProvider with ChangeNotifier {
  List<Animations> animations = [];
  Size defaultFramesSize = Size(256, 256);
  List<String> toNotify = [];
  int selectedAnimationIndex = 0;
  Map<String, SpriteAnimationController> spriteControllers = {};

  Animations get currentAnimation => animations[selectedAnimationIndex];
  SpriteAnimationController get currentSpriteController =>
      spriteControllers[currentAnimation.id]!;

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
    notify([
      W.editorSidebar,
      W.editorPreview,
      W.editorcontrolBar,
      W.editorFramesView,
    ]);
  }

  void toggleLoop() {
    currentAnimation.loop = !currentAnimation.loop;
    currentSpriteController.loop = currentAnimation.loop;
    notify([W.editorcontrolBar, W.editorPreview]);
  }

  void playPreview() {
    final controller = currentSpriteController;
    rewindSpriteIfFinished(controller);
    controller.play();
    notify([W.editorcontrolBar, W.editorPreview]);
  }

  void pausePreview() {
    currentSpriteController.pause();
    notify([W.editorcontrolBar, W.editorPreview]);
  }

  void togglePlayPreview() {
    if (currentSpriteController.isPlaying) {
      pausePreview();
    } else {
      playPreview();
    }
  }

  void goToPreviewFrame(int index) {
    final controller = currentSpriteController;
    controller.pause();
    controller.goToFrame(index);
    notify([W.editorcontrolBar, W.editorPreview, W.editorFramesView]);
  }

  void addNewAnimation() {
    final defaultAnimation = Animations(
      id: Uuid().v4(),
      name: "New Animation",
      frames: [],
      fps: 24,
      loop: true,
      reverse: false,
    );
    animations.add(defaultAnimation);
    createSpriteController(defaultAnimation.id);

    notify([W.editorSidebar]);
  }

  ProjectProvider() {
    final defaultAnimation = Animations(
      id: Uuid().v4(),
      name: 'default',
      frames: [],
      fps: 24,
      loop: true,
      reverse: false,
    );
    animations.add(defaultAnimation);
    createSpriteController(defaultAnimation.id);
  }

  void createSpriteController(String id) {
    final controller = SpriteAnimationController(autoPlay: false);
    controller.onComplete = () {
      notify([W.editorcontrolBar]);
    };
    spriteControllers[id] = controller;
  }

  void addNewFrame(String input) async {
    final currentAnimationOutputPath =
        "${Cache.tempPath!}/${currentAnimation.id}";

    if (!(await Directory(currentAnimationOutputPath).exists())) {
      await Directory(currentAnimationOutputPath).create();
    }

    final outputPath =
        "$currentAnimationOutputPath/${path.basenameWithoutExtension(path.basename(input))}.png";

    await FFmpegCommands.resizeImage(input, outputPath, defaultFramesSize);

    final frame = Frame(
      id: Uuid().v4(),
      name: path.basename(input),
      size: defaultFramesSize,
      imagePath: outputPath,
    );

    currentAnimation.frames.add(frame);

    notify([W.editorFramesView, W.editorPreview]);
  }

  Future<void> addFramesFromSpritesheet({
    required String spritesheetPath,
    required SpritesheetSlice slice,
    required List<({int col, int row})> selectionOrder,
  }) async {
    final currentAnimationOutputPath =
        "${Cache.tempPath!}/${currentAnimation.id}";

    if (!(await Directory(currentAnimationOutputPath).exists())) {
      await Directory(currentAnimationOutputPath).create();
    }

    final baseName = path.basenameWithoutExtension(
      path.basename(spritesheetPath),
    );

    for (final cell in selectionOrder) {
      final outputPath =
          "$currentAnimationOutputPath/${baseName}_r${cell.row}c${cell.col}.png";

      final cropRect = slice.cellRect(cell.col, cell.row);

      await FFmpegCommands.cropAndResize(
        spritesheetPath,
        outputPath,
        cropRect,
        defaultFramesSize,
      );

      final frame = Frame(
        id: Uuid().v4(),
        name: '$baseName [${cell.row},${cell.col}]',
        size: defaultFramesSize,
        imagePath: outputPath,
      );

      currentAnimation.frames.add(frame);
    }

    notify([W.editorFramesView, W.editorPreview]);
  }

  void removeFrame(int index) {
    final frames = currentAnimation.frames;
    if (index < 0 || index >= frames.length) return;

    final controller = currentSpriteController;
    final currentIdx = frames.isEmpty
        ? 0
        : controller.currentFrame.clamp(0, frames.length - 1);
    final wasDeletingCurrent = index == currentIdx;

    frames.removeAt(index);

    if (frames.isEmpty) {
      controller.stop();
    } else {
      final newIndex = wasDeletingCurrent
          ? index.clamp(0, frames.length - 1)
          : index < currentIdx
          ? currentIdx - 1
          : currentIdx;
      controller.goToFrame(newIndex);
    }

    notify([W.editorFramesView, W.editorPreview]);
  }

  void reorderFrames(int oldIndex, int newIndex) {
    final frames = currentAnimation.frames;
    if (oldIndex < 0 ||
        oldIndex >= frames.length ||
        newIndex < 0 ||
        newIndex > frames.length) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final controller = currentSpriteController;
    final currentFrameId =
        frames[controller.currentFrame.clamp(0, frames.length - 1)].id;

    final frame = frames.removeAt(oldIndex);
    frames.insert(newIndex, frame);

    final newCurrentIndex = frames.indexWhere((f) => f.id == currentFrameId);
    if (newCurrentIndex >= 0) {
      controller.goToFrame(newCurrentIndex);
    }

    notify([W.editorFramesView, W.editorPreview]);
  }
}

/// When loop is off, the controller stops on the last frame. [play] then
/// immediately completes again unless we rewind to the start first.
void rewindSpriteIfFinished(SpriteAnimationController controller) {
  if (controller.loop || controller.totalFrames <= 1) return;

  switch (controller.mode) {
    case PlayMode.forward:
      if (controller.currentFrame >= controller.totalFrames - 1) {
        controller.goToFrame(0);
      }
    case PlayMode.reverse:
      if (controller.currentFrame <= 0) {
        controller.goToFrame(controller.totalFrames - 1);
      }
    case PlayMode.pingPong:
      break;
  }
}
