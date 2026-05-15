import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/screens/editor/widgets/buttons_bar.dart';
import 'package:letstry/screens/editor/widgets/frames_bar.dart';
import 'package:letstry/screens/editor/widgets/preview_widget.dart';

class MainViewWidget extends StatelessWidget {
  const MainViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        children: [
          Expanded(child: PreviewWidget()),
          ButtonsBar(),
          const FramesBar(),
        ],
      ),
    );
  }
}
