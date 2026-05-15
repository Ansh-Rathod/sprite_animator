import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class ControlBarData {
  const ControlBarData({
    required this.hasFrames,
    required this.loop,
    required this.autoPlay,
  });

  final bool hasFrames;
  final bool loop;
  final bool autoPlay;

  @override
  bool operator ==(Object other) {
    return other is ControlBarData &&
        other.hasFrames == hasFrames &&
        other.loop == loop &&
        other.autoPlay == autoPlay;
  }

  @override
  int get hashCode => Object.hash(hasFrames, loop, autoPlay);
}

class ButtonsBar extends StatelessWidget {
  const ButtonsBar({super.key, required this.controller});

  final SpriteAnimationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Selector<ProjectProvider, ControlBarData>(
      selector: (_, provider) => ControlBarData(
        hasFrames: provider.currentAnimation.frames.isNotEmpty,
        loop: provider.currentAnimation.loop,
        autoPlay: provider.currentAnimation.autoPlay,
      ),
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorcontrolBar, context) ||
          shouldRebuildVideo(W.editorFramesView, context),
      builder: (context, data, _) {
        final provider = context.read<ProjectProvider>();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final enabled = data.hasFrames;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: 'Previous frame',
                    child: IconButton(
                      icon: const Icon(WindowsIcons.back),
                      onPressed: enabled
                          ? () {
                              controller.pause();
                              controller.goToFrame(
                                controller.currentFrame - 1,
                              );
                            }
                          : null,
                    ),
                  ),
                  Tooltip(
                    message: controller.isPlaying ? 'Pause' : 'Play',
                    child: IconButton(
                      icon: Icon(
                        controller.isPlaying
                            ? WindowsIcons.pause
                            : WindowsIcons.play,
                      ),
                      onPressed: enabled
                          ? () {
                              if (controller.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            }
                          : null,
                    ),
                  ),
                  Tooltip(
                    message: 'Next frame',
                    child: IconButton(
                      icon: const Icon(WindowsIcons.forward),
                      onPressed: enabled
                          ? () {
                              controller.pause();
                              controller.goToFrame(
                                controller.currentFrame + 1,
                              );
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Tooltip(
                    message: 'Loop',
                    child: IconButton(
                      icon: Icon(
                        WindowsIcons.sync,
                        color: data.loop ? theme.accentColor : null,
                      ),
                      onPressed: enabled ? provider.toggleLoop : null,
                    ),
                  ),
                  Tooltip(
                    message: 'Autoplay',
                    child: IconButton(
                      icon: Icon(
                        WindowsIcons.play_solid,
                        color: data.autoPlay ? theme.accentColor : null,
                      ),
                      onPressed: enabled ? provider.toggleAutoPlay : null,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
