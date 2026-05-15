import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/screens/editor/widgets/buttons_bar.dart';
import 'package:letstry/screens/editor/widgets/frames_bar.dart';
import 'package:letstry/screens/editor/widgets/preview_widget.dart';

class MainViewWidget extends StatefulWidget {
  const MainViewWidget({super.key});

  @override
  State<MainViewWidget> createState() => _MainViewWidgetState();
}

class _MainViewWidgetState extends State<MainViewWidget>
    with SingleTickerProviderStateMixin {
  late final SpriteAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SpriteAnimationController(autoPlay: false);
    _controller.attach(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SpriteAnimationController get controller => _controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: PreviewWidget(controller: _controller)),
        ButtonsBar(controller: _controller),
        const FramesBar(),
      ],
    );
  }
}
