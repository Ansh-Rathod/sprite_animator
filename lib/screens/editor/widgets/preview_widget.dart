import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class PreviewData {
  const PreviewData({
    required this.animationId,
    required this.framePaths,
    required this.fps,
    required this.loop,
    required this.reverse,
    required this.autoPlay,
  });

  final String animationId;
  final List<String> framePaths;
  final int fps;
  final bool loop;
  final bool reverse;
  final bool autoPlay;

  @override
  bool operator ==(Object other) {
    return other is PreviewData &&
        other.animationId == animationId &&
        other.fps == fps &&
        other.loop == loop &&
        other.reverse == reverse &&
        other.autoPlay == autoPlay &&
        _listEquals(other.framePaths, framePaths);
  }

  @override
  int get hashCode => Object.hash(
    animationId,
    fps,
    loop,
    reverse,
    autoPlay,
    Object.hashAll(framePaths),
  );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class PreviewWidget extends StatelessWidget {
  const PreviewWidget({super.key, required this.controller});

  final SpriteAnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Selector<ProjectProvider, PreviewData>(
      selector: (_, provider) => PreviewData(
        animationId: provider.currentAnimation.id,
        framePaths: provider.currentAnimation.frames
            .map((frame) => frame.imagePath)
            .toList(),
        fps: provider.currentAnimation.fps,
        loop: provider.currentAnimation.loop,
        reverse: provider.currentAnimation.reverse,
        autoPlay: provider.currentAnimation.autoPlay,
      ),
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorPreview, context),
      builder: (context, data, _) {
        return _FramePreview(
          key: ValueKey(data.animationId),
          data: data,
          controller: controller,
        );
      },
    );
  }
}

class _FramePreview extends StatefulWidget {
  const _FramePreview({
    super.key,
    required this.data,
    required this.controller,
  });

  final PreviewData data;
  final SpriteAnimationController controller;

  @override
  State<_FramePreview> createState() => _FramePreviewState();
}

class _FramePreviewState extends State<_FramePreview> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _syncController();
    _precacheFrames();
  }

  @override
  void didUpdateWidget(covariant _FramePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _syncController();
      if (!_listEquals(oldWidget.data.framePaths, widget.data.framePaths)) {
        _precacheFrames();
      }
    }
  }

  void _syncController() {
    final data = widget.data;
    final controller = widget.controller;

    controller.fps = data.fps.toDouble();
    controller.loop = data.loop;
    controller.mode = data.reverse ? PlayMode.reverse : PlayMode.forward;

    final frameCount = data.framePaths.length;
    if (frameCount == 0) {
      // setupGrid(0) and goToFrame(0) both call clamp(0, -1) and throw.
      controller.stop();
      return;
    }

    controller.setupGrid(totalFrames: frameCount);

    if (data.autoPlay && frameCount > 1) {
      controller.play();
    } else if (controller.isPlaying) {
      controller.pause();
    }
  }

  Future<void> _precacheFrames() async {
    final paths = widget.data.framePaths;
    if (paths.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    await SpriteAnimation.precacheAll(
      paths.map((path) => FileImage(File(path))).toList(),
      context,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final framePaths = widget.data.framePaths;

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (framePaths.isEmpty) {
          return Center(
            child: Text('Add frames to preview', style: theme.typography.body),
          );
        }

        final maxIndex = framePaths.length - 1;
        final index = widget.controller.currentFrame.clamp(0, maxIndex);

        return Center(
          child: Image.file(File(framePaths[index]), fit: BoxFit.contain),
        );
      },
    );
  }
}
