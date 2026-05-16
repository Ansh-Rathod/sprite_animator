import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/screens/editor/widgets/add_frames_actions.dart';

class AddFramesButton extends StatefulWidget {
  const AddFramesButton({super.key});

  @override
  State<AddFramesButton> createState() => _AddFramesButtonState();
}

class _AddFramesButtonState extends State<AddFramesButton> {
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
              text: const Text('Pick separate images'),
              onPressed: () {
                Navigator.of(context).pop();
                pickSeparateImages(this.context);
              },
            ),
            MenuFlyoutItem(
              text: const Text('Pick spritesheet'),
              onPressed: () {
                Navigator.of(context).pop();
                pickSpritesheet(this.context);
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

    return Tooltip(
      message: "Add frames",
      child: FlyoutTarget(
        controller: _flyoutController,
        child: IconButton(
          onPressed: _showMenu,

          icon: const Icon(WindowsIcons.add),
        ),
      ),
    );
  }
}
