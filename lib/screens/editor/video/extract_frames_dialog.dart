import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:provider/provider.dart';

Future<void> showExtractFramesDialog(
  BuildContext context, {
  required String videoPath,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      fullscreenDialog: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ExtractFramesPage(videoPath: videoPath);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class ExtractFramesPage extends StatefulWidget {
  final String videoPath;

  const ExtractFramesPage({super.key, required this.videoPath});

  @override
  State<ExtractFramesPage> createState() => _ExtractFramesPageState();
}

class _ExtractFramesPageState extends State<ExtractFramesPage> {
  int _fps = 24;
  bool _isProcessing = false;

  String get _videoName {
    return widget.videoPath.split('/').last.split('\\').last;
  }

  Future<void> _extract() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await context.read<ProjectProvider>().addFramesFromVideo(
        videoPath: widget.videoPath,
        fps: _fps,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      await showDialog<void>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Failed to extract frames'),
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
                Text('Extract Video Frames', style: theme.typography.subtitle),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.resources.solidBackgroundFillColorSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.resources.cardStrokeColorDefault,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            WindowsIcons.video,
                            size: 32,
                            color: theme.accentColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _videoName,
                                  style: theme.typography.bodyStrong,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Video file selected',
                                  style: theme.typography.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Frames Per Second (FPS)',
                      style: theme.typography.bodyStrong,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Higher FPS = more frames, smoother animation but larger output.',
                      style: theme.typography.caption,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 140,
                      child: NumberBox(
                        value: _fps,
                        min: 1,
                        max: 120,
                        mode: SpinButtonPlacementMode.inline,
                        clearButton: false,
                        onChanged: (v) {
                          if (v != null) setState(() => _fps = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                  onPressed: _isProcessing ? null : _extract,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: ProgressRing(strokeWidth: 2),
                        )
                      : const Text('Extract Frames'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
