import 'package:letstry/models/frame.dart';

class Animations {
  final String id;
  String name;
  List<Frame> frames;
  int fps;
  bool loop;
  bool reverse;

  Animations({
    required this.id,
    required this.name,
    required this.frames,
    required this.fps,
    required this.loop,
    required this.reverse,
  });

  factory Animations.fromJson(Map<String, dynamic> json) {
    return Animations(
      id: json['id'],
      name: json['name'],
      frames: json['frames'].map((frame) => Frame.fromJson(frame)).toList(),
      fps: json['fps'],
      loop: json['loop'],
      reverse: json['reverse'],
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
    };
  }
}
