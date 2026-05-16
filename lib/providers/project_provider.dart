import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:letstry/cache.dart';
import 'package:letstry/models/animations.dart';
import 'package:letstry/models/frame.dart';
import 'package:letstry/models/project.dart';
import 'package:letstry/models/spritesheet_slice.dart';
import 'package:letstry/services/ffmpeg.dart';
import 'package:letstry/services/hive_service.dart';
import 'package:letstry/utils/screens.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> projects = [];
  List<String> toNotify = [];
  final List<Frame> _clipboard = [];

  Project? _currentProject;
  Project? get currentProject => _currentProject;
  Map<String, SpriteAnimationController> spriteControllers = {};

  List<Animations> get animations => _currentProject?.animations ?? [];
  int get selectedAnimationIndex => _currentProject?.selectedAnimationIndex ?? 0;
  set selectedAnimationIndex(int value) {
    if (_currentProject != null) _currentProject!.selectedAnimationIndex = value;
  }
  Animations get currentAnimation => animations[selectedAnimationIndex];
  SpriteAnimationController get currentSpriteController =>
      spriteControllers[currentAnimation.id]!;

  bool get hasClipboard => _clipboard.isNotEmpty;

  // ── Project lifecycle ──

  Future<void> loadProjects() async {
    projects = await HiveService.loadProjects();
    notifyListeners();
  }

  void createProject(String name) {
    final project = Project(
      id: Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      animations: [
        Animations(
          id: Uuid().v4(),
          name: 'default',
          frames: [],
          fps: 12,
          loop: true,
          reverse: false,
          frameSize: const Size(256, 256),
        ),
      ],
    );
    projects.add(project);
    _currentProject = project;
    spriteControllers.clear();
    createSpriteController(project.animations[0].id);
    HiveService.saveProject(project);
    notifyListeners();
  }

  void openProject(String id) {
    final project = projects.firstWhere((p) => p.id == id);
    _currentProject = project;
    spriteControllers.clear();
    for (final anim in project.animations) {
      createSpriteController(anim.id);
    }
    notify([
      W.editorSidebar,
      W.editorPreview,
      W.editorFramesView,
      W.editorcontrolBar,
    ]);
  }

  void deleteProject(String id) {
    HiveService.deleteProject(id);
    projects.removeWhere((p) => p.id == id);
    if (_currentProject?.id == id) {
      _currentProject = null;
    }
    notifyListeners();
  }

  // ── Auto-save ──

  Future<void> _autoSave() async {
    if (_currentProject == null) return;
    _currentProject!.updatedAt = DateTime.now();
    await HiveService.saveProject(_currentProject!);
    final idx = projects.indexWhere((p) => p.id == _currentProject!.id);
    if (idx >= 0) projects[idx] = _currentProject!;
  }

  // ── Clipboard ──

  void copyFrames(List<int> indices) {
    _clipboard.clear();
    final frames = currentAnimation.frames;
    for (final index in indices) {
      if (index < 0 || index >= frames.length) continue;
      final f = frames[index];
      _clipboard.add(Frame(
        id: Uuid().v4(),
        name: f.name,
        size: f.size,
        imagePath: f.imagePath,
      ));
    }
  }

  void pasteFrames() {
    if (_clipboard.isEmpty) return;
    final frames = currentAnimation.frames;
    for (final f in _clipboard) {
      frames.add(Frame(
        id: Uuid().v4(),
        name: f.name,
        size: f.size,
        imagePath: f.imagePath,
      ));
    }
    _autoSave();
    notify([W.editorFramesView, W.editorPreview]);
  }

  // ── Notifications ──

  void notify(List<String> texts) {
    toNotify.addAll(texts);
    notifyListeners();
  }

  // ── Animation selection ──

  void setSelectedAnimationIndex(int index) {
    selectedAnimationIndex = index;
    _autoSave();
    notify([
      W.editorSidebar,
      W.editorPreview,
      W.editorcontrolBar,
      W.editorFramesView,
    ]);
  }

  // ── Playback ──

  void toggleLoop() {
    currentAnimation.loop = !currentAnimation.loop;
    currentSpriteController.loop = currentAnimation.loop;
    _autoSave();
    notify([W.editorcontrolBar, W.editorPreview]);
  }

  void setPlayDirection(bool reverse) {
    final controller = currentSpriteController;
    final alreadyInDirection = currentAnimation.reverse == reverse;

    if (alreadyInDirection && controller.isPlaying) {
      pausePreview();
      return;
    }

    currentAnimation.reverse = reverse;
    controller.mode = reverse ? PlayMode.reverse : PlayMode.forward;
    rewindSpriteIfFinished(controller);
    controller.play();
    _autoSave();
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

  String? recentlyAdded;

  // ── Animation CRUD ──

  void addNewAnimation() {
    final defaultAnimation = Animations(
      id: Uuid().v4(),
      name: "New Animation",
      frames: [],
      fps: 12,
      loop: true,
      reverse: false,
      frameSize: const Size(256, 256),
    );
    animations.add(defaultAnimation);
    setSelectedAnimationIndex(animations.indexOf(defaultAnimation));
    createSpriteController(defaultAnimation.id);
    recentlyAdded = defaultAnimation.id;
    _autoSave();
    notify([W.editorSidebar]);
  }

  void deleteAnimation(Animations animation) {
    spriteControllers.remove(animation.id);
    animations.remove(animation);
    if (animations.isNotEmpty) setSelectedAnimationIndex(0);
    _autoSave();
    notify([
      W.editorFramesView,
      W.editorPreview,
      W.editorSidebar,
      W.editorcontrolBar,
    ]);
  }

  void renameAnimation(String animationId, String newName) {
    final anim = animations.firstWhere((a) => a.id == animationId);
    anim.name = newName;
    _autoSave();
  }

  void setAnimationName(String animationId, String newName) {
    final anim = animations.firstWhere((a) => a.id == animationId);
    anim.name = newName;
  }

  // ── FPS / Frame size ──

  void setFps(int fps) {
    currentAnimation.fps = fps;
    _autoSave();
    notify([W.editorFramesView, W.editorPreview]);
  }

  void setFrameSize(Size size) {
    currentAnimation.frameSize = size;
    _autoSave();
    notify([W.editorcontrolBar, W.editorFramesView, W.editorPreview]);
  }

  // ── Sprite controllers ──

  void createSpriteController(String id) {
    final controller = SpriteAnimationController(autoPlay: false);
    controller.onComplete = () {
      notify([W.editorcontrolBar]);
    };
    spriteControllers[id] = controller;
  }

  // ── Frame operations ──

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
      currentAnimation.frameSize,
    );

    final frame = Frame(
      id: Uuid().v4(),
      name: path.basename(input),
      size: currentAnimation.frameSize,
      imagePath: outputPath,
    );

    currentAnimation.frames.add(frame);

    await _autoSave();
    notify([W.editorFramesView, W.editorPreview]);
  }

  Future<void> addFramesFromVideo({
    required String videoPath,
    required int fps,
  }) async {
    final outputDir = "${Cache.tempPath!}/${currentAnimation.id}/video_frames";

    final framePaths = await FFmpegCommands.extractVideoFrames(
      videoPath,
      outputDir,
      fps,
      currentAnimation.frameSize,
    );

    for (var i = 0; i < framePaths.length; i++) {
      final frame = Frame(
        id: Uuid().v4(),
        name: '${i + 1}',
        size: currentAnimation.frameSize,
        imagePath: framePaths[i],
      );
      currentAnimation.frames.add(frame);
    }

    await _autoSave();
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

    for (var i = 0; i < selectionOrder.length; i++) {
      final cell = selectionOrder[i];
      final outputPath =
          "$currentAnimationOutputPath/${baseName}_r${cell.row}c${cell.col}.png";

      final cropRect = slice.cellRect(cell.col, cell.row);

      await FFmpegCommands.cropAndResize(
        spritesheetPath,
        outputPath,
        cropRect,
        currentAnimation.frameSize,
      );

      final frame = Frame(
        id: Uuid().v4(),
        name: '${i + 1}',
        size: currentAnimation.frameSize,
        imagePath: outputPath,
      );

      currentAnimation.frames.add(frame);
    }

    await _autoSave();
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

    _autoSave();
    notify([W.editorFramesView, W.editorPreview]);
  }

  void removeFrames(List<int> indices) {
    if (indices.isEmpty) return;

    final frames = currentAnimation.frames;
    final controller = currentSpriteController;
    int currentIdx = controller.currentFrame.clamp(0, frames.length - 1);

    final sorted = List.of(indices)..sort((a, b) => b.compareTo(a));

    for (final index in sorted) {
      if (index < 0 || index >= frames.length) continue;
      frames.removeAt(index);
      if (index < currentIdx) currentIdx--;
    }

    if (frames.isEmpty) {
      controller.stop();
    } else {
      controller.goToFrame(currentIdx.clamp(0, frames.length - 1));
    }

    _autoSave();
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

    _autoSave();
    notify([W.editorFramesView, W.editorPreview]);
  }
}

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
