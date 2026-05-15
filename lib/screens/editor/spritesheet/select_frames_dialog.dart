import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/models/spritesheet_slice.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/spritesheet/slice_sidebar.dart';
import 'package:letstry/screens/editor/spritesheet/spritesheet_preview.dart';
import 'package:letstry/screens/editor/widgets/add_frames_actions.dart';
import 'package:provider/provider.dart';

Future<void> showSelectFramesDialog(
  BuildContext context, {
  required String spritesheetPath,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SelectFramesDialog(spritesheetPath: spritesheetPath),
  );
}

class SelectFramesDialog extends StatefulWidget {
  final String spritesheetPath;

  const SelectFramesDialog({super.key, required this.spritesheetPath});

  @override
  State<SelectFramesDialog> createState() => _SelectFramesDialogState();
}

class _SelectFramesDialogState extends State<SelectFramesDialog> {
  final GlobalKey<SpritesheetPreviewState> _previewKey =
      GlobalKey<SpritesheetPreviewState>();

  SpritesheetSlice _slice = SpritesheetSlice();
  ui.Size? _imageSize;
  final List<({int col, int row})> _selection = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final size = await loadImageSize(widget.spritesheetPath);
      if (!mounted) return;

      setState(() {
        _imageSize = size;
        _slice = SpritesheetSlice(
          columns: 1,
          rows: 1,
          cellSize: size ?? const ui.Size(256, 256),
        );
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _previewKey.currentState?.fitToView(const Size(600, 400));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleCell(({int col, int row}) cell) {
    setState(() {
      final existingIndex = _selection.indexWhere(
        (c) => c.col == cell.col && c.row == cell.row,
      );
      if (existingIndex >= 0) {
        _selection.removeAt(existingIndex);
      } else {
        _selection.add(cell);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selection.clear();
      for (var row = 0; row < _slice.rows; row++) {
        for (var col = 0; col < _slice.columns; col++) {
          _selection.add((col: col, row: row));
        }
      }
    });
  }

  void _selectNone() {
    setState(() => _selection.clear());
  }

  void _autoSlice() {
    if (_imageSize == null) return;
    setState(() {
      _slice.applyAutoSlice(_imageSize!);
    });
  }

  Future<void> _confirm() async {
    if (_selection.isEmpty || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await context.read<ProjectProvider>().addFramesFromSpritesheet(
        spritesheetPath: widget.spritesheetPath,
        slice: _slice,
        selectionOrder: List.of(_selection),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      await showDialog<void>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Failed to add frames'),
          content: Text(e.toString()),
          actions: [
            FilledButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final screenSize = MediaQuery.sizeOf(context);

    final maxWidth = screenSize.width * 0.92;
    final maxHeight = screenSize.height * 0.88;
    final minWidth = math.min(900.0, maxWidth);
    final minHeight = math.min(650.0, maxHeight);
    final contentWidth = math.min(screenSize.width * 0.85, maxWidth);
    final contentHeight = math.max(
      240.0,
      math.min(screenSize.height * 0.7, maxHeight - 100),
    );

    return ContentDialog(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      title: const Text('Select Frames'),
      content: SizedBox(
        width: contentWidth,
        height: contentHeight,
        child: _isLoading
            ? const Center(child: ProgressRing())
            : _error != null
            ? Center(child: Text(_error!))
            : Column(
                children: [
                  Row(
                    children: [
                      Button(
                        onPressed: _selectAll,
                        child: const Text('Select All'),
                      ),
                      const SizedBox(width: 8),
                      Button(
                        onPressed: _selectNone,
                        child: const Text('Select None'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.resources.cardStrokeColorDefault,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _imageSize == null
                                  ? const SizedBox.shrink()
                                  : SpritesheetPreview(
                                      key: _previewKey,
                                      imagePath: widget.spritesheetPath,
                                      imageSize: _imageSize!,
                                      slice: _slice,
                                      selection: _selection,
                                      onCellTapped: _toggleCell,
                                    ),
                            ),
                          ),
                        ),
                        SliceSidebar(
                          slice: _slice,
                          onChanged: (slice) => setState(() => _slice = slice),
                          onAutoSlice: _autoSlice,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        Button(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selection.isEmpty || _isProcessing ? null : _confirm,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: ProgressRing(strokeWidth: 2),
                )
              : Text(
                  _selection.isEmpty
                      ? 'Add Frame(s)'
                      : 'Add ${_selection.length} Frame(s)',
                ),
        ),
      ],
    );
  }
}
