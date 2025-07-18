import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/models/models.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<ContentItem> _trashedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrashedItems();
  }

  Future<void> _loadTrashedItems() async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      final items = await contentRepository.getTrashItems();

      if (mounted) {
        setState(() {
          _trashedItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading trash: $e')));
      }
    }
  }

  Future<void> _restoreItem(ContentItem item) async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      await contentRepository.restoreItem(item.id);
      await _loadTrashedItems(); // Reload items

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${item.name} restored')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error restoring item: $e')));
      }
    }
  }

  Future<void> _deleteItemPermanently(ContentItem item) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text(
          'Are you sure you want to permanently delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
        await contentRepository.deleteItemPermanently(item.id);
        await _loadTrashedItems(); // Reload items

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name} deleted permanently')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
        }
      }
    }
  }

  Future<void> _emptyTrash() async {
    if (_trashedItems.isEmpty) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: Text(
          'Are you sure you want to permanently delete all ${_trashedItems.length} items in the trash? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Empty Trash'),
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

        // Show progress dialog for multiple deletions
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Emptying trash...'),
              ],
            ),
          ),
        );

        // Delete all trashed items
        for (final item in _trashedItems) {
          await contentRepository.deleteItemPermanently(item.id);
        }

        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          await _loadTrashedItems(); // Reload items

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Trash emptied')));
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error emptying trash: $e')));
        }
      }
    }
  }

  String _getItemTypeText(ContentType type) {
    switch (type) {
      case ContentType.folder:
        return 'Folder';
      case ContentType.note:
        return 'Note';
      case ContentType.task:
        return 'Task';
      case ContentType.image:
        return 'Image';
    }
  }

  Color _getItemTypeColor(ContentType type) {
    switch (type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trash (${_trashedItems.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrashedItems,
            tooltip: 'Refresh',
          ),
          if (_trashedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _emptyTrash,
              tooltip: 'Empty Trash',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trashedItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Trash is empty'),
                  SizedBox(height: 8),
                  Text(
                    'Deleted items will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTrashedItems,
              child: ListView.builder(
                itemCount: _trashedItems.length,
                itemBuilder: (context, index) {
                  final item = _trashedItems[index];
                  final typeColor = _getItemTypeColor(item.type);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getItemTypeText(item.type),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: typeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (item.isFavorite)
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deleted on ${_formatDate(item.modifiedAt)}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForContentType(item.type),
                          color: typeColor,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.restore,
                              color: Colors.green,
                            ),
                            onPressed: () => _restoreItem(item),
                            tooltip: 'Restore',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteItemPermanently(item),
                            tooltip: 'Delete Permanently',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  IconData _getIconForContentType(ContentType type) {
    switch (type) {
      case ContentType.folder:
        return Icons.folder;
      case ContentType.note:
        return Icons.description;
      case ContentType.task:
        return Icons.check_circle;
      case ContentType.image:
        return Icons.image;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
