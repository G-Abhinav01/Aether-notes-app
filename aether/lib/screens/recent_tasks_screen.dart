import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/models/models.dart';
import 'package:aether/services/settings_service.dart';

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
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    // Get recent items limit from settings
    final limit = settingsService.getRecentItemsLimit();
    
    final tasks = await contentRepository.getRecentTasks(limit: limit);
    
    setState(() {
      _recentTasks = tasks;
      _isLoading = false;
    });
  }
  
  Future<void> _toggleTaskCompletion(Task task) async {
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    await contentRepository.toggleTaskCompletion(task.id);
    await _loadRecentTasks(); // Reload tasks
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Tasks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentTasks.isEmpty
              ? const Center(child: Text('No recent tasks'))
              : ListView.builder(
                  itemCount: _recentTasks.length,
                  itemBuilder: (context, index) {
                    final task = _recentTasks[index];
                    return ListTile(
                      title: Text(
                        task.name,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty)
                            Text(
                              task.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            _formatDate(task.modifiedAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(task),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/task/${task.id}',
                        );
                      },
                    );
                  },
                ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}