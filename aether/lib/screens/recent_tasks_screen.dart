import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/settings_service.dart';
import 'package:aether/models/models.dart';

class RecentTasksScreen extends StatefulWidget {
  const RecentTasksScreen({super.key});

  @override
  State<RecentTasksScreen> createState() => _RecentTasksScreenState();
}

class _RecentTasksScreenState extends State<RecentTasksScreen> {
  List<Task> _recentTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentTasks();
  }

  Future<void> _loadRecentTasks() async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final settingsService = Provider.of<SettingsService>(
        context,
        listen: false,
      );

      // Get recent items limit from settings
      final limit = settingsService.getRecentItemsLimit();

      final tasks = await contentRepository.getRecentTasks(limit: limit);

      if (mounted) {
        setState(() {
          _recentTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recent tasks: $e')),
        );
      }
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      await contentRepository.toggleTaskCompletion(task.id);
      await _loadRecentTasks(); // Reload tasks

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              task.isCompleted ? 'Task marked incomplete' : 'Task completed!',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
      }
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  Widget _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Icon(Icons.keyboard_arrow_down, size: 16);
      case TaskPriority.medium:
        return const Icon(Icons.remove, size: 16);
      case TaskPriority.high:
        return const Icon(Icons.keyboard_arrow_up, size: 16);
      case TaskPriority.urgent:
        return const Icon(Icons.priority_high, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentTasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No recent tasks'),
                  SizedBox(height: 8),
                  Text(
                    'Create a task to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRecentTasks,
              child: ListView.builder(
                itemCount: _recentTasks.length,
                itemBuilder: (context, index) {
                  final task = _recentTasks[index];
                  final isOverdue = task.isOverdue();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        task.name,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? Colors.grey
                              : isOverdue
                              ? Colors.red
                              : null,
                          fontWeight: isOverdue && !task.isCompleted
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty)
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: task.isCompleted ? Colors.grey : null,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Priority indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    task.priority,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _getPriorityIcon(task.priority),
                                    const SizedBox(width: 2),
                                    Text(
                                      task.priority.name,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getPriorityColor(task.priority),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Due date
                              if (task.dueDate != null) ...[
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: isOverdue ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _formatDate(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isOverdue ? Colors.red : Colors.grey,
                                    fontWeight: isOverdue
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                                if (isOverdue) ...[
                                  const SizedBox(width: 4),
                                  const Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 8),
                              ],

                              // Modified date
                              Text(
                                'Modified: ${_formatDate(task.modifiedAt)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                            ],
                          ),

                          // Tags
                          if (task.tags.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: task.tags
                                  .take(3)
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(task),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.isFavorite)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        context.push('/task/${task.id}');
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
