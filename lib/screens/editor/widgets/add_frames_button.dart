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

    return Column(
      children: [
        FlyoutTarget(
          controller: _flyoutController,
          child: GestureDetector(
            onTap: _showMenu,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              width: 100,
              height: 100,
              child: const Icon(WindowsIcons.add),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add frames',
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body!.copyWith(
            fontSize: 12,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
