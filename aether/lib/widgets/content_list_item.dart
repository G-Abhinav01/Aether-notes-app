import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aether/models/models.dart';

class ContentListItem extends StatelessWidget {
  final ContentItem item;
  final bool isSelected;
  final bool showPath;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ContentListItem({
    super.key,
    required this.item,
    this.isSelected = false,
    this.showPath = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: _buildLeading(context),
        title: _buildTitle(context),
        subtitle: _buildSubtitle(context),
        trailing: _buildTrailing(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    switch (item.type) {
      case ContentType.folder:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder, color: Colors.blue, size: 24),
        );

      case ContentType.note:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.note, color: Colors.green, size: 24),
        );

      case ContentType.task:
        final task = item as Task;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            task.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.isCompleted
                ? Colors.green
                : _getPriorityColor(task.priority),
            size: 24,
          ),
        );

      case ContentType.image:
        final imageItem = item as ImageItem;
        if (File(imageItem.filePath).existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imageItem.filePath),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.broken_image,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
          );
        }
    }
  }

  Widget _buildTitle(BuildContext context) {
    final title = item.name.isNotEmpty ? item.name : _getDefaultName();

    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        decoration: item.type == ContentType.task && (item as Task).isCompleted
            ? TextDecoration.lineThrough
            : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final List<Widget> subtitleElements = [];

    // Add content preview for notes and tasks
    if (item.type == ContentType.note) {
      final note = item as Note;
      if (note.content.isNotEmpty) {
        subtitleElements.add(
          Text(
            note.content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
    } else if (item.type == ContentType.task) {
      final task = item as Task;
      if (task.description.isNotEmpty) {
        subtitleElements.add(
          Text(
            task.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
    } else if (item.type == ContentType.image) {
      final imageItem = item as ImageItem;
      subtitleElements.add(
        Text(
          '${imageItem.metadata.width} × ${imageItem.metadata.height} • ${_formatFileSize(imageItem.fileSize)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }

    // Add path if requested (for search results)
    if (showPath && item.parentId != null) {
      subtitleElements.add(
        Text(
          'in ${_getParentPath()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Add metadata row
    final metadataElements = <Widget>[];

    // Date
    metadataElements.add(
      Text(
        _formatDate(item.modifiedAt),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );

    // Task priority
    if (item.type == ContentType.task) {
      final task = item as Task;
      metadataElements.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            task.priority.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getPriorityColor(task.priority),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (metadataElements.isNotEmpty) {
      subtitleElements.add(
        Row(
          children: metadataElements
              .expand((element) => [element, const SizedBox(width: 8)])
              .take(metadataElements.length * 2 - 1)
              .toList(),
        ),
      );
    }

    if (subtitleElements.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subtitleElements
          .expand((element) => [element, const SizedBox(height: 4)])
          .take(subtitleElements.length * 2 - 1)
          .toList(),
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    final List<Widget> trailingElements = [];

    // Favorite indicator
    if (item.isFavorite) {
      trailingElements.add(
        const Icon(Icons.star, color: Colors.amber, size: 16),
      );
    }

    // Tags indicator
    if (item.tags.isNotEmpty) {
      trailingElements.add(
        Icon(
          Icons.label,
          color: Theme.of(context).colorScheme.outline,
          size: 16,
        ),
      );
    }

    if (trailingElements.isEmpty) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: trailingElements
          .expand((element) => [element, const SizedBox(width: 4)])
          .take(trailingElements.length * 2 - 1)
          .toList(),
    );
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

  String _getParentPath() {
    // This would need to be implemented with actual path resolution
    // For now, return a placeholder
    return 'Parent Folder';
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
