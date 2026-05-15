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
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      fullscreenDialog: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SelectFramesPage(spritesheetPath: spritesheetPath);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class SelectFramesPage extends StatefulWidget {
  final String spritesheetPath;

  const SelectFramesPage({super.key, required this.spritesheetPath});

  @override
  State<SelectFramesPage> createState() => _SelectFramesPageState();
}

class _SelectFramesPageState extends State<SelectFramesPage> {
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
        final box = _previewKey.currentContext?.findRenderObject();
        if (box is RenderBox && box.hasSize) {
          _previewKey.currentState?.fitToView(box.size);
        }
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

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.resources.cardStrokeColorDefault,
                ),
              ),
            ),
            child: Row(
              children: [
                Text('Select Frames', style: theme.typography.subtitle),
                const SizedBox(width: 16),
                Button(
                  onPressed: _isLoading ? null : _selectAll,
                  child: const Text('Select All'),
                ),
                const SizedBox(width: 8),
                Button(
                  onPressed: _isLoading ? null : _selectNone,
                  child: const Text('Select None'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: ProgressRing())
                : _error != null
                ? Center(child: Text(_error!))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                          ),
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
                      SliceSidebar(
                        slice: _slice,
                        onChanged: (slice) => setState(() => _slice = slice),
                      ),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.resources.cardStrokeColorDefault,
                ),
              ),
            ),
            child: Row(
              children: [
                Button(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
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
            ),
          ),
        ],
      ),
    );
  }
}
