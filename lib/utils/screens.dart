import 'package:flutter/material.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:provider/provider.dart';

class W {
  static String editorSidebar = "editorSidebar";
  static String editorFramesView = "editorFramesView";
  static String editorPreview = "editorPreview";
  static String editorcontrolBar = "editorcontrolBar";
}

bool shouldRebuildVideo(
  String text,
  BuildContext context, [
  bool removeFromRebuild = true,
]) {
  final rebuildList = context.read<ProjectProvider>().toNotify;
  final rebuild = rebuildList.contains(text);
  if (removeFromRebuild) {
    context.read<ProjectProvider>().toNotify.remove(text);
  }
  return rebuild;
}
