import 'package:letstry/models/animations.dart';

class Project {
  final String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  List<Animations> animations;
  int selectedAnimationIndex;

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.animations,
    this.selectedAnimationIndex = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      animations: (json['animations'] as List)
          .map((a) => Animations.fromJson(a))
          .toList(),
      selectedAnimationIndex: json['selectedAnimationIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'animations': animations.map((a) => a.toJson()).toList(),
      'selectedAnimationIndex': selectedAnimationIndex,
    };
  }
}
