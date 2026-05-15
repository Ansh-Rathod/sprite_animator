import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class FramesBar extends StatelessWidget {
  const FramesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Selector<ProjectProvider, ProjectProvider>(
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
                          state.notify([
                            W.editorFramesView,
                            W.editorPreview,
                          ]);
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
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.currentAnimation.frames.length + 1,
                  separatorBuilder: (context, index) => 10.w,
                  itemBuilder: (context, index) {
                    if (index == state.currentAnimation.frames.length) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final images = await FilePicker.pickFiles(
                                type: FileType.image,
                              );
                              if (images == null) {
                                return;
                              }
                              for (var image in images.files) {
                                state.addNewFrame(image.path!);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: 100,
                              height: 100,
                              child: Icon(WindowsIcons.add),
                            ),
                          ),
                          4.h,
                          Text(
                            "Add frames",
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.body!.copyWith(
                              fontSize: 12,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      );
                    }
                    final frame = state.currentAnimation.frames[index];
                    return SizedBox(
                      width: 100,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.file(
                                File(frame.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          4.h,
                          Text(
                            frame.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.body!.copyWith(
                              fontSize: 12,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      selector: (context, state) => state,
      shouldRebuild: (previous, next) =>
          shouldRebuildVideo(W.editorFramesView, context),
    );
  }
}
