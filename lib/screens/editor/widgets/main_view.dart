import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/screens/editor/widgets/buttons_bar.dart';
import 'package:letstry/screens/editor/widgets/frames_bar.dart';
import 'package:letstry/screens/editor/widgets/preview_widget.dart';

class MainViewWidget extends StatefulWidget {
  const MainViewWidget({super.key});

  @override
  State<MainViewWidget> createState() => _MainViewWidgetState();
}

class _MainViewWidgetState extends State<MainViewWidget> {
  double _currentHeight = 200.0;

  static const double _minHeight = 120.0;
  static const double _maxHeight = 400.0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentHeight = (_currentHeight - details.delta.dy).clamp(
        _minHeight,
        _maxHeight,
      );
    });
  }

  Widget _buildResizeHandle(FluentThemeData theme) {
    bool isHover = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (event) => setState(() => isHover = true),
          onExit: (event) => setState(() => isHover = false),
          cursor: SystemMouseCursors.resizeRow,
          child: GestureDetector(
            onVerticalDragUpdate: _onDragUpdate,
            child: Container(
              // height: 10,
              width: double.infinity,
              // padding: EdgeInsets.only(bottom: 4, top: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,

                border: Border(
                  top: isHover
                      ? BorderSide(width: 2, color: theme.accentColor)
                      : BorderSide(width: 0.4, color: theme.shadowColor),
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 40,
                // height: 2,
                decoration: BoxDecoration(
                  color: theme.resources.textFillColorSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        children: [
          Expanded(child: PreviewWidget()),
          Column(
            children: [
              _buildResizeHandle(theme),

              ButtonsBar(),
              FramesBar(height: _currentHeight),
            ],
          ),
        ],
      ),
    );
  }
}
