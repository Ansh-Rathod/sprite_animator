import 'package:letstry/models/frame.dart';

class Animations {
  final String id;
  String name;
  List<Frame> frames;
  int fps;
  bool loop;
  bool autoPlay;
  bool reverse;

  Animations({
    required this.id,
    required this.name,
    required this.frames,
    required this.fps,
    required this.loop,
    required this.autoPlay,
    required this.reverse,
  });

  factory Animations.fromJson(Map<String, dynamic> json) {
    return Animations(
      id: json['id'],
      name: json['name'],
      frames: json['frames'].map((frame) => Frame.fromJson(frame)).toList(),
      fps: json['fps'],
      loop: json['loop'],
      autoPlay: json['autoPlay'],
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
      'autoPlay': autoPlay,
      'reverse': reverse,
    };
  }
}
