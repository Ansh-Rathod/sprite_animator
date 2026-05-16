import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/widgets/add_frames_button.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class ControlBarData {
  const ControlBarData({
    required this.hasFrames,
    required this.loop,
    required this.reverse,
  });

  final bool hasFrames;
  final bool loop;
  final bool reverse;

  @override
  bool operator ==(Object other) {
    return other is ControlBarData &&
        other.hasFrames == hasFrames &&
        other.loop == loop &&
        other.reverse == reverse;
  }

  @override
  int get hashCode => Object.hash(hasFrames, loop, reverse);
}

class ButtonsBar extends StatelessWidget {
  const ButtonsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Selector<ProjectProvider, ControlBarData>(
      selector: (_, provider) => ControlBarData(
        hasFrames: provider.currentAnimation.frames.isNotEmpty,
        loop: provider.currentAnimation.loop,
        reverse: provider.currentAnimation.reverse,
      ),
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorcontrolBar, context),
      builder: (context, data, _) {
        final provider = context.read<ProjectProvider>();
        final controller = provider.currentSpriteController;
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,

            border: Border(
              bottom: BorderSide(width: 0.3, color: theme.shadowColor),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("FPS:", style: theme.typography.body),
              2.w,
              Transform.scale(
                scale: 0.85,
                child: SizedBox(
                  width: 100,
                  child: NumberBox(
                    clearButton: false,
                    value: provider.currentAnimation.fps,
                    onChanged: (v) {
                      provider.currentAnimation.fps = v ?? 24;
                      provider.notify([W.editorFramesView, W.editorPreview]);
                    },
                    mode: SpinButtonPlacementMode.inline,
                  ),
                ),
              ),
              Spacer(),

              RotatedBox(
                quarterTurns: 4,
                child: Tooltip(
                  message: 'Play in reverse',
                  child: IconButton(
                    icon: Icon(
                      FluentIcons.play_reverse_resume,
                      color: data.reverse ? theme.accentColor : null,
                    ),
                    onPressed: () => provider.setPlayDirection(true),
                  ),
                ),
              ),
              Tooltip(
                message: 'Previous frame',
                child: IconButton(
                  icon: const Icon(WindowsIcons.back),
                  onPressed: () {
                    controller.pause();
                    controller.goToFrame(controller.currentFrame - 1);
                    provider.notify([W.editorcontrolBar, W.editorPreview]);
                  },
                ),
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final isPlaying = controller.isPlaying;
                  return Tooltip(
                    message: isPlaying ? 'Pause' : 'Play',
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? WindowsIcons.pause : WindowsIcons.play,
                      ),
                      onPressed: provider.togglePlayPreview,
                    ),
                  );
                },
              ),
              Tooltip(
                message: 'Next frame',
                child: IconButton(
                  icon: const Icon(WindowsIcons.forward),
                  onPressed: () {
                    controller.pause();
                    controller.goToFrame(controller.currentFrame + 1);
                    provider.notify([W.editorcontrolBar, W.editorPreview]);
                  },
                ),
              ),
              RotatedBox(
                quarterTurns: 2,
                child: Tooltip(
                  message: 'Play forward',
                  child: IconButton(
                    icon: Icon(
                      FluentIcons.play_reverse_resume,
                      color: !data.reverse ? theme.accentColor : null,
                    ),
                    onPressed: () => provider.setPlayDirection(false),
                  ),
                ),
              ),
              Spacer(),

              // const SizedBox(width: 16),
              80.w,

              Tooltip(
                message: 'Loop',
                child: IconButton(
                  icon: Icon(
                    WindowsIcons.sync,
                    color: data.loop ? theme.accentColor : null,
                  ),
                  onPressed: provider.toggleLoop,
                ),
              ),
              2.w,
              AddFramesButton(),
            ],
          ),
        );
      },
    );
  }
}
