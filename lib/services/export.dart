import 'dart:convert';
import 'dart:io';

import 'package:letstry/models/animations.dart';
import 'package:letstry/services/ffmpeg.dart';
import 'package:path/path.dart' as p;

class ExportService {
  static const int maxColumns = 10;

  static Future<void> exportToZip(
    List<Animations> animations,
    String outputZipPath,
  ) async {
    final tempDir = Directory.systemTemp.createTempSync('spritesheet_export_');
    try {
      await _exportAnimationsToDir(animations, tempDir);

      final zipArgs = [
        '-j',
        '-X',
        outputZipPath,
        ...tempDir.listSync().map((e) => e.path),
      ];
      final result = await Process.run('zip', zipArgs);

      if (result.exitCode != 0) {
        throw Exception('Failed to create zip: ${result.stderr}');
      }
    } finally {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  }

  static Future<void> _exportAnimationsToDir(
    List<Animations> animations,
    Directory directory,
  ) async {
    for (final animation in animations) {
      final frames = animation.frames;
      if (frames.isEmpty) continue;

      final frameW = animation.frameSize.width.toInt();
      final frameH = animation.frameSize.height.toInt();
      final count = frames.length;
      final columns = count < maxColumns ? count : maxColumns;
      final rows = (count / columns).ceil();
      final sheetW = columns * frameW;
      final sheetH = rows * frameH;
      final durationMs = (1000 / animation.fps).round();
      final safeName = _safeFileName(animation.name);

      final imagePaths = frames.map((f) => f.imagePath).toList();

      final spritesheetPath = p.join(directory.path, '${safeName}.png');
      await FFmpegCommands.buildSpritesheet(
        imagePaths,
        spritesheetPath,
        columns,
        rows,
      );

      final asepriteFrames = <Map<String, dynamic>>[];
      for (var i = 0; i < frames.length; i++) {
        final x = (i % columns) * frameW;
        final y = (i ~/ columns) * frameH;
        asepriteFrames.add({
          'filename': '${safeName}_$i.png',
          'frame': {
            'x': x,
            'y': y,
            'w': frameW,
            'h': frameH,
          },
          'rotated': false,
          'trimmed': false,
          'spriteSourceSize': {
            'x': 0,
            'y': 0,
            'w': frameW,
            'h': frameH,
          },
          'sourceSize': {'w': frameW, 'h': frameH},
          'duration': durationMs,
        });
      }

      final json = {
        'frames': asepriteFrames,
        'meta': {
          'app': 'letstry',
          'version': '1.0.0',
          'image': '${safeName}.png',
          'format': 'RGBA8888',
          'size': {'w': sheetW, 'h': sheetH},
          'scale': '1',
          'frameTags': [
            {
              'name': animation.name,
              'from': 0,
              'to': frames.length - 1,
              'direction': animation.reverse ? 'reverse' : 'forward',
            },
          ],
          'layers': [
            {'name': 'main', 'opacity': 255, 'blendMode': 'normal'},
          ],
        },
      };

      final jsonPath = p.join(directory.path, '${safeName}.json');
      await File(jsonPath).writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
    }
  }

  static String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w-]'), '_');
  }
}
