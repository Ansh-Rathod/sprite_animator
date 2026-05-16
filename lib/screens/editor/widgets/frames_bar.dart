import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:letstry/models/frame.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/widgets/add_frames_button.dart';
import 'package:letstry/screens/editor/widgets/buttons_bar.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:letstry/utils/screens.dart';
import 'package:letstry/widgets/checkers_background.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

class FramesBar extends StatefulWidget {
  final double height;
  const FramesBar({super.key, required this.height});

  @override
  State<FramesBar> createState() => _FramesBarState();
}

class _FramesBarState extends State<FramesBar> {
  final Set<int> _selectedIndices = {};
  int? _lastClickedIndex;

  void _handlePlainTap(int index) {
    if (_selectedIndices.isNotEmpty) {
      setState(() {
        // _selectedIndices.clear();
        _selectedIndices.add(index);
        _lastClickedIndex = index;
      });
    } else {
      context.read<ProjectProvider>().goToPreviewFrame(index);
    }
  }

  void _handleShiftTap(int index) {
    if (_lastClickedIndex == null) {
      _handlePlainTap(index);
      return;
    }
    setState(() {
      final start = _lastClickedIndex! < index ? _lastClickedIndex! : index;
      final end = _lastClickedIndex! < index ? index : _lastClickedIndex!;
      for (var i = start; i <= end; i++) {
        _selectedIndices.add(i);
      }
    });
  }

  void _handleModifierTap(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _lastClickedIndex = index;
    });
  }

  void _removeAllSelected() {
    if (_selectedIndices.isEmpty) return;
    context.read<ProjectProvider>().removeFrames(_selectedIndices.toList());
    setState(() {
      _selectedIndices.clear();
      _lastClickedIndex = null;
    });
  }

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
          height: widget.height,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.h,
              // if (_selectedIndices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    8.w,
                    Text(
                      _selectedIndices.isEmpty
                          ? "Frames"
                          : 'Selected frames (${_selectedIndices.length})',
                      style: theme.typography.bodyStrong,
                    ),
                    6.w,
                    FrameSizeButton(),
                    const Spacer(),
                    if (_selectedIndices.isNotEmpty)
                      Tooltip(
                        message: 'Copy',
                        child: IconButton(
                          icon: const Icon(WindowsIcons.copy),
                          onPressed: () {
                            state.copyFrames(_selectedIndices.toList());
                            setState(() {
                              _selectedIndices.clear();
                              _lastClickedIndex = null;
                            });
                          },
                        ),
                      ),
                    4.w,
                    if (state.hasClipboard)
                      Tooltip(
                        message: 'Paste',
                        child: IconButton(
                          icon: const Icon(WindowsIcons.paste),
                          onPressed: () {
                            state.pasteFrames();
                          },
                        ),
                      ),
                    4.w,

                    if (_selectedIndices.isNotEmpty) ...[
                      Tooltip(
                        message: 'Remove All',
                        child: IconButton(
                          icon: const Icon(WindowsIcons.delete),
                          onPressed: _removeAllSelected,
                        ),
                      ),
                      4.w,
                    ],

                    Tooltip(
                      message: 'Select / Deselect All',
                      child: IconButton(
                        icon: _selectedIndices.isEmpty
                            ? const Icon(FluentIcons.multi_select)
                            : const Icon(FluentIcons.clear_selection),
                        onPressed: () {
                          if (_selectedIndices.isEmpty) {
                            final count = state.currentAnimation.frames.length;
                            setState(() {
                              _selectedIndices.clear();
                              _selectedIndices.addAll(
                                List.generate(count, (i) => i),
                              );
                              _lastClickedIndex = count > 0 ? count - 1 : null;
                            });
                          } else {
                            setState(() {
                              _selectedIndices.clear();
                              _lastClickedIndex = null;
                            });
                          }
                        },
                      ),
                    ),
                    4.w,

                    AddFramesButton(),

                    2.w,
                    // Tooltip(
                    //   message: 'Deselect All',
                    //   child: IconButton(
                    //     icon: const Icon(WindowsIcons.cancel),
                    //     onPressed: () {
                    //       setState(() {
                    //         _selectedIndices.clear();
                    //         _lastClickedIndex = null;
                    //       });
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
              8.h,
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
                          onReorder: (oldIndex, newIndex) {
                            state.reorderFrames(oldIndex, newIndex);
                            setState(() {
                              _selectedIndices.clear();
                              _lastClickedIndex = null;
                            });
                          },
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
                            final isCurrent = index == currentFrame;
                            final isMultiSel = _selectedIndices.contains(index);
                            final selectionMode = _selectedIndices.isNotEmpty;
                            return SizedBox(
                              key: ValueKey(frame.id),
                              width: 100,
                              child: FrameWidget(
                                frame: frame,
                                isSelected: isCurrent,
                                isMultiSelected: isMultiSel,
                                selectionMode: selectionMode,
                                onRemove: () {
                                  state.removeFrame(index);
                                },
                                onTap: () => _handlePlainTap(index),
                                onShiftTap: () => _handleShiftTap(index),
                                onModifierTap: () => _handleModifierTap(index),
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
  final bool isMultiSelected;
  final bool selectionMode;
  final Frame frame;
  final void Function() onRemove;
  final void Function() onTap;
  final void Function() onShiftTap;
  final void Function() onModifierTap;

  const FrameWidget({
    super.key,
    required this.isSelected,
    required this.isMultiSelected,
    required this.selectionMode,
    required this.frame,
    required this.onRemove,
    required this.onTap,
    required this.onShiftTap,
    required this.onModifierTap,
  });

  @override
  State<FrameWidget> createState() => _FrameWidgetState();
}

class _FrameWidgetState extends State<FrameWidget> {
  Frame get frame => widget.frame;
  bool get isSelected => widget.isSelected;
  bool get isMultiSelected => widget.isMultiSelected;
  bool get selectionMode => widget.selectionMode;
  bool isHover = false;
  final FlyoutController _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
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
              text: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onModifierTap();
              },
            ),
            MenuFlyoutItem(
              text: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRemove();
              },
            ),
          ],
        );
      },
    );
  }

  void _onTapDown(TapDownDetails details) {
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isShiftPressed) {
      widget.onShiftTap();
    } else if (keyboard.isMetaPressed || keyboard.isControlPressed) {
      widget.onModifierTap();
    } else {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return MouseRegion(
      onEnter: (e) {
        setState(() => isHover = true);
      },
      onExit: (e) {
        setState(() => isHover = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTapDown: _onTapDown,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? theme.accentColor
                            : isMultiSelected
                            ? theme.accentColor.withValues(alpha: 0.5)
                            : theme.cardColor,
                        width: isSelected ? 2 : 1,
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
                if (isMultiSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                if (selectionMode)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: GestureDetector(
                      onTap: widget.onModifierTap,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isMultiSelected
                              ? theme.accentColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isMultiSelected
                                ? theme.accentColor
                                : theme.resources.textFillColorSecondary,
                            width: 2,
                          ),
                        ),
                        child: isMultiSelected
                            ? Icon(
                                WindowsIcons.check_mark,
                                size: 12,
                                color: theme.resources.textFillColorPrimary,
                              )
                            : null,
                      ),
                    ),
                  ),
                if (!selectionMode && isHover)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FlyoutTarget(
                      controller: _flyoutController,
                      child: GestureDetector(
                        // onTap: _showMenu,
                        child: IconButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              theme.accentColor,
                            ),
                          ),

                          // width: 22,
                          // height: 22,
                          // decoration: BoxDecoration(
                          //   color: theme.cardColor,
                          //   shape: BoxShape.circle,
                          //   border: Border.all(
                          //     color: theme.resources.textFillColorSecondary,
                          //     width: 2,
                          //   ),
                          // ),
                          onPressed: _showMenu,
                          icon: Icon(
                            WindowsIcons.more,
                            size: 10,
                            color: theme.resources.textFillColorPrimary,
                          ),
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
            textAlign: TextAlign.center,
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
