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
  });

  final String animationId;
  final List<String> framePaths;
  final int fps;
  final bool loop;
  final bool reverse;

  @override
  bool operator ==(Object other) {
    return other is PreviewData &&
        other.animationId == animationId &&
        other.fps == fps &&
        other.loop == loop &&
        other.reverse == reverse &&
        _listEquals(other.framePaths, framePaths);
  }

  @override
  int get hashCode => Object.hash(
    animationId,
    fps,
    loop,
    reverse,
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
  const PreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProjectProvider, ProjectProvider>(
      selector: (_, provider) => provider,
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorPreview, context),
      builder: (context, provider, _) {
        return _FramePreview(
          key: ValueKey(provider.currentAnimation.id),
          data: PreviewData(
            animationId: provider.currentAnimation.id,
            framePaths: provider.currentAnimation.frames
                .map((frame) => frame.imagePath)
                .toList(),
            fps: provider.currentAnimation.fps,
            loop: provider.currentAnimation.loop,
            reverse: provider.currentAnimation.reverse,
          ),
          controller: provider.currentSpriteController,
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

class _FramePreviewState extends State<_FramePreview>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  int _precacheGeneration = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.attach(this);
    _syncController();
    _precacheFrames();
  }

  @override
  void dispose() {
    _precacheGeneration++;
    if (widget.controller.isPlaying) {
      widget.controller.pause();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FramePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller.attach(this);
    }
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
  }

  Future<void> _precacheFrames() async {
    final paths = widget.data.framePaths;
    final generation = ++_precacheGeneration;

    if (paths.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      await SpriteAnimation.precacheAll(
        paths.map((path) => FileImage(File(path))).toList(),
        context,
      );
    } catch (e, stack) {
      debugPrint('Frame precache failed: $e\n$stack');
    } finally {
      if (mounted && generation == _precacheGeneration) {
        setState(() => _isLoading = false);
      }
    }
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

    if (framePaths.isEmpty) {
      return Center(
        child: Text('Add frames to preview', style: theme.typography.body),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final maxIndex = framePaths.length - 1;
            final index = widget.controller.currentFrame.clamp(0, maxIndex);

            return Center(
              child: Image.file(File(framePaths[index]), fit: BoxFit.contain),
            );
          },
        ),
        if (_isLoading)
          const Positioned(
            top: 12,
            child: SizedBox(
              width: 24,
              height: 24,
              child: ProgressRing(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}
