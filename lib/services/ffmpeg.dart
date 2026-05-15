import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class FFmpegCommands {
  /// macOS .app layout: `Contents/MacOS/<executable>` → `Contents/Resources/ffmpeg`.
  static String _ffmpegExecutable() {
    if (!Platform.isMacOS) return 'ffmpeg';
    final resolved = File(Platform.resolvedExecutable);
    final bundled = p.join(resolved.parent.parent.path, 'Resources', 'ffmpeg');
    if (File(bundled).existsSync()) return bundled;
    return 'ffmpeg';
  }

  static Future<String> resizeImage(
    String inputPath,
    String outputPath,
    Size size, {
    bool maintainAspectRatio = true,
    int quality = 2, // 2 = best quality, higher = more compression
  }) async {
    final File inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      throw Exception('Input file does not exist: $inputPath');
    }

    final List<String> arguments = [
      '-i', inputPath,
      '-vf',
      maintainAspectRatio
          ? 'scale=${size.width.round()}:-1:flags=lanczos' // High quality + keep ratio
          : 'scale=${size.width.round()}:${size.height.round()}',
      '-q:v', quality.toString(),
      '-y', // Overwrite output without asking
      outputPath,
    ];

    final String ffmpegBin = _ffmpegExecutable();

    try {
      final result = await Process.run(ffmpegBin, arguments);

      if (result.exitCode == 0) {
        debugPrint('Image resized successfully: $outputPath');
        return outputPath;
      } else {
        debugPrint('FFmpeg Error: ${result.stderr}');
        throw Exception('Failed to resize image: ${result.stderr}');
      }
    } on ProcessException catch (e) {
      debugPrint('Exception while running FFmpeg: $e');
      if (e.message.contains('Operation not permitted') && Platform.isMacOS) {
        throw Exception(
          'Cannot run ffmpeg (macOS blocked the process). '
          'Use a build with App Sandbox disabled, or add a static ffmpeg binary at '
          'YourApp.app/Contents/Resources/ffmpeg and enable sandbox again.',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Exception while running FFmpeg: $e');
      rethrow;
    }
  }

  static Future<String> cropAndResize(
    String inputPath,
    String outputPath,
    Rect cropRect,
    Size targetSize, {
    bool maintainAspectRatio = true,
    int quality = 2,
  }) async {
    final File inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      throw Exception('Input file does not exist: $inputPath');
    }

    final x = cropRect.left.round().clamp(0, 1 << 30);
    final y = cropRect.top.round().clamp(0, 1 << 30);
    final w = cropRect.width.round().clamp(1, 1 << 30);
    final h = cropRect.height.round().clamp(1, 1 << 30);

    final scaleFilter = maintainAspectRatio
        ? 'scale=${targetSize.width.round()}:-1:flags=lanczos'
        : 'scale=${targetSize.width.round()}:${targetSize.height.round()}';

    final List<String> arguments = [
      '-i',
      inputPath,
      '-vf',
      'crop=$w:$h:$x:$y,$scaleFilter',
      '-q:v',
      quality.toString(),
      '-y',
      outputPath,
    ];

    final String ffmpegBin = _ffmpegExecutable();

    try {
      final result = await Process.run(ffmpegBin, arguments);

      if (result.exitCode == 0) {
        debugPrint('Image cropped successfully: $outputPath');
        return outputPath;
      } else {
        debugPrint('FFmpeg Error: ${result.stderr}');
        throw Exception('Failed to crop image: ${result.stderr}');
      }
    } on ProcessException catch (e) {
      debugPrint('Exception while running FFmpeg: $e');
      if (e.message.contains('Operation not permitted') && Platform.isMacOS) {
        throw Exception(
          'Cannot run ffmpeg (macOS blocked the process). '
          'Use a build with App Sandbox disabled, or add a static ffmpeg binary at '
          'YourApp.app/Contents/Resources/ffmpeg and enable sandbox again.',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Exception while running FFmpeg: $e');
      rethrow;
    }
  }
}
