import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aether/models/models.dart';

class ContentGridItem extends StatelessWidget {
  final ContentItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ContentGridItem({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content preview/icon
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getTypeColor(context).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: _buildContentPreview(context),
              ),
            ),

            // Content info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.name.isNotEmpty ? item.name : _getDefaultName(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Metadata
                    Row(
                      children: [
                        Icon(
                          _getTypeIcon(),
                          size: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(item.modifiedAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Additional indicators
                    if (item.isFavorite || item.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.isFavorite) ...[
                            Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 4),
                          ],
                          if (item.tags.isNotEmpty)
                            Icon(
                              Icons.label,
                              size: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview(BuildContext context) {
    switch (item.type) {
      case ContentType.folder:
        return Center(
          child: Icon(Icons.folder, size: 48, color: _getTypeColor(context)),
        );

      case ContentType.note:
        final note = item as Note;
        if (note.content.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              note.content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return Center(
            child: Icon(Icons.note, size: 48, color: _getTypeColor(context)),
          );
        }

      case ContentType.task:
        final task = item as Task;
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: task.isCompleted
                        ? Colors.green
                        : _getPriorityColor(task.priority),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? Theme.of(context).colorScheme.outline
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );

      case ContentType.image:
        final imageItem = item as ImageItem;
        if (File(imageItem.filePath).existsSync()) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.file(
              File(imageItem.filePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        } else {
          return Center(
            child: Icon(
              Icons.broken_image,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }
    }
  }

  Color _getTypeColor(BuildContext context) {
    switch (item.type) {
      case ContentType.folder:
        return Colors.blue;
      case ContentType.note:
        return Colors.green;
      case ContentType.task:
        return Colors.orange;
      case ContentType.image:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon() {
    switch (item.type) {
      case ContentType.folder:
        return Icons.folder;
      case ContentType.note:
        return Icons.note;
      case ContentType.task:
        return Icons.task_alt;
      case ContentType.image:
        return Icons.image;
    }
  }

  String _getDefaultName() {
    switch (item.type) {
      case ContentType.folder:
        return 'Untitled Folder';
      case ContentType.note:
        return 'Untitled Note';
      case ContentType.task:
        return 'Untitled Task';
      case ContentType.image:
        return 'Untitled Image';
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
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
