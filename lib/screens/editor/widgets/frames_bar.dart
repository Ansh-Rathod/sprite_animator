import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/widgets/add_frames_button.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class FramesBar extends StatelessWidget {
  const FramesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Selector<ProjectProvider, ProjectProvider>(
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorFramesView, context),
      builder: (context, state, _) {
        return Container(
          decoration: BoxDecoration(color: theme.cardColor),
          height: 200,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.h,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text("Frames", style: theme.typography.subtitle),
                    Spacer(),
                    Text("FPS:", style: theme.typography.body),
                    12.w,
                    SizedBox(
                      width: 100,
                      child: NumberBox(
                        clearButton: false,
                        value: state.currentAnimation.fps,
                        onChanged: (v) {
                          state.currentAnimation.fps = v ?? 24;
                          state.notify([W.editorFramesView, W.editorPreview]);
                        },
                        mode: SpinButtonPlacementMode.inline,
                      ),
                    ),
                  ],
                ),
              ),
              12.h,
              SizedBox(
                height: 140,
                child: AnimatedBuilder(
                  animation: state.currentSpriteController,
                  builder: (context, _) {
                    final currentFrame =
                        state.currentSpriteController.currentFrame;
                    final frames = state.currentAnimation.frames;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: frames.isEmpty
                              ? const SizedBox.shrink()
                              : ReorderableListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(left: 20),
                                  buildDefaultDragHandles: false,
                                  onReorder: state.reorderFrames,
                                  itemCount: frames.length,
                                  proxyDecorator: (child, index, animation) {
                                    return AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        final t = Curves.easeInOut.transform(
                                          animation.value,
                                        );
                                        return Transform.scale(
                                          scale: 1 + 0.04 * t,
                                          child: Opacity(
                                            opacity: 0.92,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: child,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    final frame = frames[index];
                                    final isSelected = index == currentFrame;
                                    return Padding(
                                      key: ValueKey(frame.id),
                                      padding: EdgeInsets.only(
                                        right: index < frames.length - 1
                                            ? 10
                                            : 0,
                                      ),
                                      child: SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  ReorderableDragStartListener(
                                                    index: index,
                                                    child: Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? theme
                                                                    .accentColor
                                                              : Colors
                                                                    .transparent,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            2,
                                                          ),
                                                      child: GestureDetector(
                                                        onTap: () => state
                                                            .goToPreviewFrame(
                                                              index,
                                                            ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: Image.file(
                                                            File(
                                                              frame.imagePath,
                                                            ),
                                                            fit: BoxFit.cover,
                                                            width: 96,
                                                            height: 96,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: -4,
                                                    right: -4,
                                                    child: GestureDetector(
                                                      onTap: () => state
                                                          .removeFrame(index),
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: theme
                                                                  .shadowColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: Icon(
                                                          FluentIcons.cancel,
                                                          size: 10,
                                                          color: theme
                                                              .resources
                                                              .textFillColorPrimary,
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
                                              style: theme.typography.body!
                                                  .copyWith(
                                                    fontSize: 12,
                                                    letterSpacing: -0.2,
                                                    color: isSelected
                                                        ? theme.accentColor
                                                        : null,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (frames.isNotEmpty) 10.w,
                        Padding(
                          padding: EdgeInsets.only(
                            left: frames.isEmpty ? 20 : 0,
                            right: 20,
                          ),
                          child: const AddFramesButton(),
                        ),
                      ],
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
