import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:letstry/models/project.dart';

class HiveService {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('projects');
  }

  static Future<List<Project>> loadProjects() async {
    final projects = <Project>[];
    for (final value in _box.values) {
      projects.add(Project.fromJson(Map<String, dynamic>.from(value)));
    }
    return projects;
  }

  static Future<void> saveProject(Project project) async {
    await _box.put(project.id, project.toJson());
  }

  static Future<void> deleteProject(String id) async {
    await _box.delete(id);
  }
}
