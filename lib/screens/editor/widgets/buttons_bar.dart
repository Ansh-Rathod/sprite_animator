import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class ControlBarData {
  const ControlBarData({
    required this.hasFrames,
    required this.loop,
  });

  final bool hasFrames;
  final bool loop;

  @override
  bool operator ==(Object other) {
    return other is ControlBarData &&
        other.hasFrames == hasFrames &&
        other.loop == loop;
  }

  @override
  int get hashCode => Object.hash(hasFrames, loop);
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
      ),
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorcontrolBar, context),
      builder: (context, data, _) {
        final provider = context.read<ProjectProvider>();
        final controller = provider.currentSpriteController;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const SizedBox(width: 16),
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
            ],
          ),
        );
      },
    );
  }
}
