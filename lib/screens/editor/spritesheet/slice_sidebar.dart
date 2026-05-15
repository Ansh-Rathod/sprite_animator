import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/models/spritesheet_slice.dart';

class SliceSidebar extends StatelessWidget {
  final SpritesheetSlice slice;
  final ValueChanged<SpritesheetSlice> onChanged;

  const SliceSidebar({super.key, required this.slice, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.resources.cardStrokeColorDefault),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _labeledField(
              context,
              label: 'Horizontal',
              child: NumberBox(
                value: slice.columns.toDouble(),
                min: 1,
                clearButton: false,
                mode: SpinButtonPlacementMode.inline,
                onChanged: (v) {
                  if (v == null) return;
                  onChanged(slice.copyWith(columns: v.round().clamp(1, 9999)));
                },
              ),
            ),
            const SizedBox(height: 12),
            _labeledField(
              context,
              label: 'Vertical',
              child: NumberBox(
                value: slice.rows.toDouble(),
                min: 1,
                clearButton: false,
                mode: SpinButtonPlacementMode.inline,
                onChanged: (v) {
                  if (v == null) return;
                  onChanged(slice.copyWith(rows: v.round().clamp(1, 9999)));
                },
              ),
            ),
            const SizedBox(height: 12),
            Text('Size', style: theme.typography.bodyStrong),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: NumberBox(
                    value: slice.cellSize.width,
                    min: 1,
                    clearButton: false,
                    mode: SpinButtonPlacementMode.inline,
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(
                        slice.copyWith(
                          cellSize: Size(v, slice.cellSize.height),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text('px', style: theme.typography.caption),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: NumberBox(
                    value: slice.cellSize.height,
                    min: 1,
                    clearButton: false,
                    mode: SpinButtonPlacementMode.inline,
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(
                        slice.copyWith(cellSize: Size(slice.cellSize.width, v)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text('px', style: theme.typography.caption),
              ],
            ),
            const SizedBox(height: 12),
            Text('Separation', style: theme.typography.bodyStrong),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: NumberBox(
                    value: slice.separation.width,
                    min: 0,
                    clearButton: false,
                    mode: SpinButtonPlacementMode.inline,
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(
                        slice.copyWith(
                          separation: Size(v, slice.separation.height),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text('px', style: theme.typography.caption),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: NumberBox(
                    value: slice.separation.height,
                    min: 0,
                    clearButton: false,
                    mode: SpinButtonPlacementMode.inline,
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(
                        slice.copyWith(
                          separation: Size(slice.separation.width, v),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text('px', style: theme.typography.caption),
              ],
            ),
            const SizedBox(height: 12),
            Text('Offset', style: theme.typography.bodyStrong),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: NumberBox(
                    value: slice.offset.dx,
                    min: 0,
                    clearButton: false,
                    mode: SpinButtonPlacementMode.inline,
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(
                        slice.copyWith(offset: Offset(v, slice.offset.dy)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text('px', style: theme.typography.caption),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: NumberBox(
                    value: slice.offset.dy,
                    min: 0,
                    clearButton: false,
                    mode: SpinButtonPlacementMode.inline,
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(
                        slice.copyWith(offset: Offset(slice.offset.dx, v)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text('px', style: theme.typography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledField(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    final theme = FluentTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.typography.bodyStrong),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
