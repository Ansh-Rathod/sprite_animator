import 'package:fluent_ui/fluent_ui.dart' hide FilledButton;
import 'package:letstry/models/animations.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/widgets/main_view.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(final BuildContext context) {
    // final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    return Selector<ProjectProvider, ProjectProvider>(
      selector: (context, state) => state,
      shouldRebuild: (previous, next) {
        return shouldRebuildVideo(W.editorSidebar, context);
      },
      child: const Expanded(child: MainViewWidget()),
      builder: (context, state, child) {
        return Container(
          decoration: BoxDecoration(color: theme.micaBackgroundColor),
          child: Column(
            children: [
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    bottom: BorderSide(width: 0.4, color: theme.shadowColor),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border(
                          right: BorderSide(
                            width: 0.3,
                            color: theme.shadowColor,
                          ),
                        ),
                      ),

                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          10.h,

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Animations",
                                  style: theme.typography.subtitle!.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Spacer(),
                                Tooltip(
                                  message: "Add New Animation",
                                  child: IconButton(
                                    icon: WindowsIcon(WindowsIcons.add),
                                    onPressed: () {
                                      state.addNewAnimation();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.animations.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              return SidebarItem(
                                animation: state.animations[index],
                                isSelected:
                                    index == state.selectedAnimationIndex,
                                onTap: () {
                                  state.setSelectedAnimationIndex(index);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    child!,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SidebarItem extends StatefulWidget {
  final Animations animation;
  final bool isSelected;
  final void Function() onTap;
  const SidebarItem({
    super.key,
    required this.animation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          setState(() => isHovered = true);
        },
        onExit: (event) {
          setState(() => isHovered = false);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isSelected
                ? theme.accentColor
                : isHovered
                ? theme.scaffoldBackgroundColor
                : Colors.transparent,
          ),
          child: Row(
            children: [
              4.w,
              Text(widget.animation.name),
              Spacer(),
              Tooltip(
                message: "more options",
                child: IconButton(
                  icon: Icon(WindowsIcons.more, size: 12),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
