// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/models/frame.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:letstry/utils/screens.dart';
import 'package:letstry/widgets/checkers_background.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

class FramesBar extends StatelessWidget {
  final double height;
  const FramesBar({super.key, required this.height});

  int _calculateCrossAxisCount(double availableWidth) {
    const double cellWidth = 110.0;
    return (availableWidth / cellWidth).floor().clamp(1, 20);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Selector<ProjectProvider, ProjectProvider>(
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorFramesView, context),
      builder: (context, state, _) {
        return Container(
          decoration: BoxDecoration(color: theme.cardColor),
          height: height,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.h,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _calculateCrossAxisCount(
                      constraints.maxWidth,
                    );
                    return AnimatedBuilder(
                      animation: state.currentSpriteController,
                      builder: (context, _) {
                        final currentFrame =
                            state.currentSpriteController.currentFrame;
                        final frames = state.currentAnimation.frames;
                        if (frames.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return ReorderableGridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 100 / 130,
                              ),
                          itemCount: frames.length,
                          onReorder: state.reorderFrames,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          proxyDecorator: (child, index, animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                final t = Curves.easeInOut.transform(
                                  animation.value,
                                );
                                return Transform.scale(
                                  scale: 1 + 0.04 * t,
                                  child: Opacity(opacity: 0.92, child: child),
                                );
                              },
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            final frame = frames[index];
                            final isSelected = index == currentFrame;
                            return SizedBox(
                              key: ValueKey(frame.id),
                              width: 100,
                              child: FrameWidget(
                                frame: frame,
                                isSelected: isSelected,
                                onRemove: () {
                                  state.removeFrame(index);
                                },
                                onTap: () {
                                  state.goToPreviewFrame(index);
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      selector: (context, state) => state,
    );
  }
}

class FrameWidget extends StatefulWidget {
  final bool isSelected;
  final Frame frame;
  final void Function() onRemove;
  final void Function() onTap;

  const FrameWidget({
    super.key,
    required this.isSelected,
    required this.frame,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<FrameWidget> createState() => _FrameWidgetState();
}

class _FrameWidgetState extends State<FrameWidget> {
  Frame get frame => widget.frame;
  bool get isSelected => widget.isSelected;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return MouseRegion(
      onEnter: (e) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (e) {
        setState(() {
          isHover = false;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? theme.accentColor : theme.cardColor,
                        width: !isSelected ? 1 : 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CheckersBackground(
                        child: Image.file(
                          File(frame.imagePath),
                          fit: BoxFit.cover,
                          width: 96,
                          height: 96,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isHover)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.shadowColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FluentIcons.cancel,
                          size: 10,
                          color: theme.resources.textFillColorPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          4.h,
          Text(
            frame.name,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body!.copyWith(
              fontSize: 12,
              letterSpacing: -0.2,
              color: isSelected ? theme.accentColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
