// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:letstry/models/frame.dart';

class Animations {
  final String id;
  String name;
  List<Frame> frames;
  int fps;
  bool loop;
  bool reverse;
  Size frameSize;

  Animations({
    required this.id,
    required this.name,
    required this.frames,
    required this.fps,
    required this.loop,
    required this.reverse,
    required this.frameSize,
  });

  factory Animations.fromJson(Map<String, dynamic> json) {
    return Animations(
      id: json['id'],
      name: json['name'],
      frames: json['frames'].map((frame) => Frame.fromJson(frame)).toList(),
      fps: json['fps'],
      loop: json['loop'],
      reverse: json['reverse'],
      frameSize: Size(json['frameSize']['width'], json['frameSize']['height']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'frames': frames.map((frame) => frame.toJson()).toList(),
      'fps': fps,
      'loop': loop,
      'reverse': reverse,
      'frameSize': {'width': frameSize.width, 'height': frameSize.height},
    };
  }
}
