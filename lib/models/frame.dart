import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class Frame {
  final String id;
  final String name;
  final Size size;
  final String imagePath;

  String get fileName => path.basename(imagePath);

  Frame({
    required this.id,
    required this.name,
    required this.size,
    required this.imagePath,
  });

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      id: json['id'],
      name: json['name'],
      size: Size(json['width'], json['height']),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': {'width': size.width, 'height': size.height},
      'imagePath': imagePath,
    };
  }
}
