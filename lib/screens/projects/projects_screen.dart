import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/models/project.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/editor.dart';
import 'package:letstry/utils/extentions.dart';
import 'package:provider/provider.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
    });
  }

  void _createProject(String name) {
    final provider = context.read<ProjectProvider>();
    provider.createProject(name);
    if (!mounted) return;
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, _, _) => const EditorScreen(),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    ));
  }

  void _openProject(String id) {
    final provider = context.read<ProjectProvider>();
    provider.openProject(id);
    if (!mounted) return;
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, _, _) => const EditorScreen(),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    ));
  }

  void _deleteProject(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          Button(
            child: const Text('Delete'),
            onPressed: () {
              context.read<ProjectProvider>().deleteProject(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showNewProjectDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter a name for your project:'),
            8.h,
            TextBox(
              controller: nameController,
              placeholder: 'Project name',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            child: const Text('Create'),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              _createProject(name);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.micaBackgroundColor),
      child: Column(
        children: [
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(width: 0.4, color: theme.shadowColor),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "Projects",
                  style: theme.typography.subtitle!.copyWith(fontSize: 16),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Create new project',
                  child: IconButton(
                    icon: const Icon(WindowsIcons.add),
                    onPressed: _showNewProjectDialog,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Selector<ProjectProvider, List<Project>>(
              selector: (_, p) => p.projects,
              builder: (context, projects, _) {
                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "No projects yet",
                          style: theme.typography.body,
                        ),
                        16.h,
                        FilledButton(
                          onPressed: _showNewProjectDialog,
                          child: const Text('Create New Project'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _ProjectCard(
                      project: project,
                      onTap: () => _openProject(project.id),
                      onDelete: () =>
                          _deleteProject(project.id, project.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.scaffoldBackgroundColor
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.shadowColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  WindowsIcons.video,
                  size: 32,
                  color: theme.accentColor,
                ),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.name,
                        style: theme.typography.subtitle,
                      ),
                      4.h,
                      Text(
                        '${widget.project.animations.length} animation${widget.project.animations.length == 1 ? '' : 's'}'
                        ' · ${_formatDate(widget.project.updatedAt)}',
                        style: theme.typography.body!.copyWith(
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Delete project',
                  child: IconButton(
                    icon: const Icon(WindowsIcons.delete),
                    onPressed: widget.onDelete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
