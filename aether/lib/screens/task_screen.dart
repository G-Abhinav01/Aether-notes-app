import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/models/models.dart';

class TaskScreen extends StatefulWidget {
  final String taskId;
  
  const TaskScreen({super.key, required this.taskId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  Task? _task;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadTask();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTask() async {
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    final task = await contentRepository.getTask(widget.taskId);
    
    if (task != null) {
      setState(() {
        _task = task;
        _nameController.text = task.name;
        _descriptionController.text = task.description;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveTask() async {
    if (_task == null) return;
    
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    // Update task fields
    final updatedTask = _task!.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
    );
    
    // Save to repository
    await contentRepository.updateContentItem(updatedTask);
    
    // Update local task
    setState(() {
      _task = updatedTask;
    });
    
    // Show save confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task saved')),
    );
  }
  
  Future<void> _toggleTaskCompletion() async {
    if (_task == null) return;
    
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    // Toggle completion
    await contentRepository.toggleTaskCompletion(_task!.id);
    
    // Reload task
    await _loadTask();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_task?.name ?? 'Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
              ? const Center(child: Text('Task not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task completion checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _task!.isCompleted,
                            onChanged: (value) => _toggleTaskCompletion(),
                          ),
                          const Text('Completed'),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Task name
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Task Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Task description
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}