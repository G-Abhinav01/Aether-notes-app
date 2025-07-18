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
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    final items = await contentRepository.getTrashItems();
    
    setState(() {
      _trashedItems = items;
      _isLoading = false;
    });
  }
  
  Future<void> _restoreItem(ContentItem item) async {
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    await contentRepository.restoreItem(item.id);
    await _loadTrashedItems(); // Reload items
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} restored')),
    );
  }
  
  Future<void> _deleteItemPermanently(ContentItem item) async {
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text('Are you sure you want to permanently delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await contentRepository.deleteItemPermanently(item.id);
      await _loadTrashedItems(); // Reload items
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} deleted permanently')),
      );
    }
  }
  
  Future<void> _emptyTrash() async {
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: const Text('Are you sure you want to permanently delete all items in the trash? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // Delete all trashed items
      for (final item in _trashedItems) {
        await contentRepository.deleteItemPermanently(item.id);
      }
      
      await _loadTrashedItems(); // Reload items
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trash emptied')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
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
              ? const Center(child: Text('Trash is empty'))
              : ListView.builder(
                  itemCount: _trashedItems.length,
                  itemBuilder: (context, index) {
                    final item = _trashedItems[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        'Deleted on ${_formatDate(item.modifiedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      leading: _getIconForContentType(item.type),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: () => _restoreItem(item),
                            tooltip: 'Restore',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () => _deleteItemPermanently(item),
                            tooltip: 'Delete Permanently',
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
  
  Widget _getIconForContentType(ContentType type) {
    switch (type) {
      case ContentType.folder:
        return const Icon(Icons.folder);
      case ContentType.note:
        return const Icon(Icons.description);
      case ContentType.task:
        return const Icon(Icons.check_circle);
      case ContentType.image:
        return const Icon(Icons.image);
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}