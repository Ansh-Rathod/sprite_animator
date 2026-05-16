import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/spritesheet/select_frames_dialog.dart';
import 'package:letstry/screens/editor/video/extract_frames_dialog.dart';
import 'package:provider/provider.dart';

Future<void> pickSeparateImages(BuildContext context) async {
  final state = context.read<ProjectProvider>();
  final images = await FilePicker.pickFiles(
    type: FileType.image,
    allowMultiple: true,
  );
  if (images == null) return;

  for (final image in images.files) {
    if (image.path != null) {
      state.addNewFrame(image.path!);
    }
  }
}

Future<void> pickSpritesheet(BuildContext context) async {
  final result = await FilePicker.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) return;

  final path = result.files.single.path;
  if (path == null) return;

  if (!context.mounted) return;

  await showSelectFramesDialog(context, spritesheetPath: path);
}

Future<void> pickVideo(BuildContext context) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp4', 'avi', 'mov', 'mkv', 'webm', 'flv', 'wmv'],
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) return;

  final path = result.files.single.path;
  if (path == null) return;

  if (!context.mounted) return;

  await showExtractFramesDialog(context, videoPath: path);
}

Future<ui.Size?> loadImageSize(String imagePath) async {
  final bytes = await File(imagePath).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return ui.Size(
    frame.image.width.toDouble(),
    frame.image.height.toDouble(),
  );
}
