import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FilledButton;
import 'package:letstry/models/animations.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/widgets/main_view.dart';
import 'package:letstry/services/export.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:letstry/utils/screens.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  Future<void> _exportAnimation(
    BuildContext context,
    ProjectProvider provider,
  ) async {
    final savePath = await FilePicker.saveFile(
      dialogTitle: 'Save spritesheets as zip',
      fileName: 'spritesheets.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (savePath == null) return;

    try {
      final path = savePath.endsWith('.zip') ? savePath : '$savePath.zip';
      await ExportService.exportToZip(provider.animations, path);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Export Complete'),
          content: const Text(
            'All animations exported as Aseprite spritesheets (ZIP).',
          ),
          actions: [
            Button(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Export Failed'),
          content: Text(e.toString()),
          actions: [
            Button(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    bottom: BorderSide(width: 0.4, color: theme.shadowColor),
                  ),
                ),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Back to projects',
                      child: IconButton(
                        icon: const Icon(WindowsIcons.back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    10.w,
                    Text(
                      state.currentProject?.name ?? 'Untitled',
                      style: theme.typography.subtitle,
                    ),
                    const Spacer(),
                    Tooltip(
                      message: 'Export animation',
                      child: IconButton(
                        icon: const Icon(WindowsIcons.export),
                        onPressed: () => _exportAnimation(context, state),
                      ),
                    ),
                  ],
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
                                rename:
                                    state.recentlyAdded ==
                                    state.animations[index].id,
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
  final bool rename;
  const SidebarItem({
    super.key,
    required this.animation,
    required this.isSelected,
    required this.onTap,
    this.rename = false,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool isHovered = false;
  bool renameOpen = false;
  TextEditingController cont = TextEditingController();

  @override
  void initState() {
    cont.text = widget.animation.name;
    renameOpen = widget.rename;
    if (renameOpen) {
      context.read<ProjectProvider>().recentlyAdded = null;
      cont.selection = TextSelection(
        baseOffset: 0,
        extentOffset: cont.text.length,
      );
    }
    super.initState();
  }

  final FlyoutController _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  void makeRenameOpen() {
    setState(() {
      renameOpen = true;
      cont.selection = TextSelection(
        baseOffset: 0,
        extentOffset: cont.text.length,
      );
    });
  }

  void _showMenu() {
    _flyoutController.showFlyout(
      barrierDismissible: true,
      dismissOnPointerMoveAway: false,
      dismissWithEsc: true,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              text: const Text('Rename'),
              onPressed: () {
                makeRenameOpen();
                Navigator.of(context).pop();
              },
            ),
            MenuFlyoutItem(
              text: const Text('Delete'),
              onPressed: () {
                context.read<ProjectProvider>().deleteAnimation(
                  widget.animation,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: () {
        makeRenameOpen();
      },
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
          padding: renameOpen
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              if (renameOpen)
                Expanded(
                  child: TextBox(
                    controller: cont,
                    autofocus: true,
                    onChanged: (value) {
                      context
                          .read<ProjectProvider>()
                          .setAnimationName(widget.animation.id, cont.text);
                    },
                    onSubmitted: (v) {
                      context
                          .read<ProjectProvider>()
                          .renameAnimation(widget.animation.id, cont.text);

                      setState(() {
                        renameOpen = false;
                      });
                    },
                    onTapOutside: (v) {
                      context
                          .read<ProjectProvider>()
                          .renameAnimation(widget.animation.id, cont.text);
                      setState(() {
                        renameOpen = false;
                      });
                    },
                  ),
                )
              else
                Expanded(child: Text(widget.animation.name)),

              Tooltip(
                message: "more options",
                child: FlyoutTarget(
                  controller: _flyoutController,
                  child: IconButton(
                    icon: Icon(WindowsIcons.more, size: 12),
                    onPressed: _showMenu,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
