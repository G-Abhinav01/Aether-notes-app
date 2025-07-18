import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/models/models.dart';
import 'package:aether/widgets/breadcrumb_navigation.dart';

class TaskScreen extends StatefulWidget {
  final String taskId;

  const TaskScreen({super.key, required this.taskId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();

  Task? _task;
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;
  bool _isEditing = false;
  DateTime? _selectedDueDate;
  TaskPriority _selectedPriority = TaskPriority.medium;

  // Auto-save timer
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadTask();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final task = await contentRepository.getTask(widget.taskId);

      if (task != null) {
        setState(() {
          _task = task;
          _nameController.text = task.name;
          _descriptionController.text = task.description;
          _selectedDueDate = task.dueDate;
          _selectedPriority = task.priority;
          _isLoading = false;
        });
      } else {
        // Task not found, navigate back
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading task: $e')));
      }
    }
  }

  void _setupAutoSave() {
    _nameController.addListener(_onContentChanged);
    _descriptionController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    // Cancel existing timer
    _autoSaveTimer?.cancel();

    // Start new timer for auto-save (2 seconds after last change)
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (_hasUnsavedChanges && _task != null) {
        _saveTask();
      }
    });
  }

  Future<void> _saveTask() async {
    if (_task == null) return;

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      // Update task with current content
      final updatedTask = _task!.copyWith(
        name: _nameController.text.isNotEmpty
            ? _nameController.text
            : 'Untitled Task',
        description: _descriptionController.text,
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        modifiedAt: DateTime.now(),
      );

      await contentRepository.updateContentItem(updatedTask);

      setState(() {
        _task = updatedTask;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving task: $e')));
      }
    }
  }

  Future<void> _toggleTaskCompletion() async {
    if (_task == null) return;

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      await contentRepository.toggleTaskCompletion(_task!.id);

      // Update local task state
      setState(() {
        _task = _task!.copyWith(isCompleted: !_task!.isCompleted);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _task!.isCompleted
                  ? 'Task completed!'
                  : 'Task marked as incomplete',
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

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (_isEditing) {
      // Focus on description when entering edit mode
      _descriptionFocusNode.requestFocus();
    }
  }

  void _showTaskOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildTaskOptionsSheet(),
    );
  }

  Widget _buildTaskOptionsSheet() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              _task?.isFavorite == true ? Icons.star : Icons.star_border,
            ),
            title: Text(
              _task?.isFavorite == true
                  ? 'Remove from Favorites'
                  : 'Add to Favorites',
            ),
            onTap: () {
              Navigator.pop(context);
              _toggleFavorite();
            },
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Manage Tags'),
            onTap: () {
              Navigator.pop(context);
              _showTagsDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Set Due Date'),
            onTap: () {
              Navigator.pop(context);
              _showDatePicker();
            },
          ),
          ListTile(
            leading: const Icon(Icons.priority_high),
            title: const Text('Set Priority'),
            onTap: () {
              Navigator.pop(context);
              _showPriorityDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Export Task'),
            onTap: () {
              Navigator.pop(context);
              _exportTask();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Move to Trash'),
            onTap: () {
              Navigator.pop(context);
              _moveToTrash();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_task == null) return;

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      await contentRepository.toggleFavorite(_task!.id);

      setState(() {
        _task = _task!.copyWith(isFavorite: !_task!.isFavorite);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _task!.isFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
      }
    }
  }

  void _showTagsDialog() {
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Tags'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current tags
            if (_task?.tags.isNotEmpty == true) ...[
              const Text(
                'Current Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _task!.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _task!.removeTag(tag);
                            _hasUnsavedChanges = true;
                          });
                          Navigator.pop(context);
                          _showTagsDialog(); // Refresh dialog
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Add new tag
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Add Tag',
                hintText: 'Enter tag name',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && _task != null) {
                  setState(() {
                    _task!.addTag(value);
                    _hasUnsavedChanges = true;
                  });
                  tagController.clear();
                  Navigator.pop(context);
                  _showTagsDialog(); // Refresh dialog
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
          if (tagController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                if (_task != null) {
                  setState(() {
                    _task!.addTag(tagController.text);
                    _hasUnsavedChanges = true;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
        ],
      ),
    ).then((_) => tagController.dispose());
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskPriority.values
              .map(
                (priority) => ListTile(
                  title: Text(priority.name),
                  leading: Radio<TaskPriority>(
                    value: priority,
                    groupValue: _selectedPriority,
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                        _hasUnsavedChanges = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  trailing: _getPriorityIcon(priority),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Icon(Icons.keyboard_arrow_down, color: Colors.green);
      case TaskPriority.medium:
        return const Icon(Icons.remove, color: Colors.orange);
      case TaskPriority.high:
        return const Icon(Icons.keyboard_arrow_up, color: Colors.red);
      case TaskPriority.urgent:
        return const Icon(Icons.priority_high, color: Colors.red);
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

  Future<void> _exportTask() async {
    if (_task == null) return;

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final exportPath = await contentRepository.exportItem(_task!.id);

      if (exportPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task exported to: $exportPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting task: $e')));
      }
    }
  }

  Future<void> _moveToTrash() async {
    if (_task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Trash'),
        content: const Text(
          'Are you sure you want to move this task to trash?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move to Trash'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final contentRepository = Provider.of<ContentRepository>(
          context,
          listen: false,
        );
        await contentRepository.trashItem(_task!.id);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Task moved to trash')));
          context.pop(); // Navigate back
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error moving task to trash: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Not Found')),
        body: const Center(
          child: Text('The requested task could not be found.'),
        ),
      );
    }

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasUnsavedChanges) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                'You have unsaved changes. Do you want to save before leaving?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            ),
          );

          if (shouldSave == true) {
            await _saveTask();
          }

          if (context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_task!.name.isNotEmpty ? _task!.name : 'Untitled Task'),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveTask,
                tooltip: 'Save',
              ),
            IconButton(
              icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
              onPressed: _toggleEditing,
              tooltip: _isEditing ? 'Preview' : 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showTaskOptions,
              tooltip: 'More options',
            ),
          ],
        ),
        body: Column(
          children: [
            // Breadcrumb navigation
            const BreadcrumbNavigation(),

            // Task status and metadata
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion status
                  Row(
                    children: [
                      Checkbox(
                        value: _task!.isCompleted,
                        onChanged: _isEditing
                            ? (value) => _toggleTaskCompletion()
                            : null,
                      ),
                      Text(
                        _task!.isCompleted ? 'Completed' : 'Incomplete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _task!.isCompleted ? Colors.green : null,
                          decoration: _task!.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const Spacer(),
                      // Priority indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            _selectedPriority,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getPriorityIcon(_selectedPriority),
                            const SizedBox(width: 4),
                            Text(
                              _selectedPriority.name,
                              style: TextStyle(
                                color: _getPriorityColor(_selectedPriority),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Due date
                  if (_selectedDueDate != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: _task!.isOverdue() ? Colors.red : null,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${_formatDate(_selectedDueDate!)}',
                          style: TextStyle(
                            color: _task!.isOverdue() ? Colors.red : null,
                            fontWeight: _task!.isOverdue()
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                        if (_task!.isOverdue()) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Timestamps
                  Text(
                    'Created: ${_formatDate(_task!.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Modified: ${_formatDate(_task!.modifiedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  // Tags
                  if (_task!.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: _task!.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Task content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Title field
                    TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'Task title',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),

                    // Description field
                    Expanded(
                      child: TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        enabled: _isEditing,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Task description...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Quick actions (when editing)
        bottomNavigationBar: _isEditing ? _buildQuickActionsBar() : null,
      ),
    );
  }

  Widget _buildQuickActionsBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
            tooltip: 'Set Due Date',
          ),
          IconButton(
            icon: const Icon(Icons.priority_high),
            onPressed: _showPriorityDialog,
            tooltip: 'Set Priority',
          ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: _showTagsDialog,
            tooltip: 'Manage Tags',
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _task!.isCompleted
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
            ),
            onPressed: _toggleTaskCompletion,
            tooltip: _task!.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_hide),
            onPressed: () => _descriptionFocusNode.unfocus(),
            tooltip: 'Hide Keyboard',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
