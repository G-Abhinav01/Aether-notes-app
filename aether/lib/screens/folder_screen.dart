import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/models/models.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/widgets/content_list_item.dart';
import 'package:aether/widgets/content_grid_item.dart';
import 'package:aether/widgets/breadcrumb_navigation.dart';
import 'package:aether/widgets/content_creation_dialog.dart';

enum ViewMode { list, grid }

enum SortOption { name, dateCreated, dateModified, type }

class FolderScreen extends StatefulWidget {
  final String? folderId;

  const FolderScreen({super.key, this.folderId});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<ContentItem> _items = [];
  Folder? _currentFolder;
  bool _isLoading = true;
  ViewMode _viewMode = ViewMode.list;
  SortOption _sortOption = SortOption.name;
  bool _sortAscending = true;
  List<ContentItem> _selectedItems = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadFolderContent();
  }

  @override
  void didUpdateWidget(FolderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folderId != widget.folderId) {
      _loadFolderContent();
    }
  }

  Future<void> _loadFolderContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      // Load current folder info if we have a folder ID
      if (widget.folderId != null) {
        final folder = await contentRepository.getFolder(widget.folderId!);
        setState(() {
          _currentFolder = folder;
        });
      } else {
        setState(() {
          _currentFolder = null;
        });
      }

      // Load folder contents
      final items = await contentRepository.getItemsByFolder(widget.folderId);

      setState(() {
        _items = items;
        _isLoading = false;
      });

      _sortItems();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading folder: $e')));
      }
    }
  }

  void _sortItems() {
    setState(() {
      _items.sort((a, b) {
        int comparison;

        switch (_sortOption) {
          case SortOption.name:
            comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case SortOption.dateCreated:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case SortOption.dateModified:
            comparison = a.modifiedAt.compareTo(b.modifiedAt);
            break;
          case SortOption.type:
            comparison = a.type.index.compareTo(b.type.index);
            break;
        }

        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...SortOption.values.map(
              (option) => ListTile(
                leading: Radio<SortOption>(
                  value: option,
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value!;
                    });
                    _sortItems();
                    Navigator.pop(context);
                  },
                ),
                title: Text(_getSortOptionName(option)),
                trailing: _sortOption == option
                    ? IconButton(
                        icon: Icon(
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                        onPressed: () {
                          setState(() {
                            _sortAscending = !_sortAscending;
                          });
                          _sortItems();
                          Navigator.pop(context);
                        },
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.name:
        return 'Name';
      case SortOption.dateCreated:
        return 'Date Created';
      case SortOption.dateModified:
        return 'Date Modified';
      case SortOption.type:
        return 'Type';
    }
  }

  void _onItemTap(ContentItem item) {
    if (_isSelectionMode) {
      _toggleItemSelection(item);
    } else {
      final navigationService = Provider.of<NavigationService>(
        context,
        listen: false,
      );
      navigationService.navigateToItem(context, item);
    }
  }

  void _onItemLongPress(ContentItem item) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedItems = [item];
      });
    } else {
      _toggleItemSelection(item);
    }
  }

  void _toggleItemSelection(ContentItem item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedItems = List.from(_items);
    });
  }

  void _showContentCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => ContentCreationDialog(
        parentFolderId: widget.folderId,
        onContentCreated: () {
          _loadFolderContent(); // Refresh the folder content
        },
      ),
    );
  }

  Future<void> _deleteSelectedItems() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Trash'),
        content: Text(
          'Are you sure you want to move ${_selectedItems.length} item(s) to trash?',
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

        for (final item in _selectedItems) {
          await contentRepository.trashItem(item.id);
        }

        _exitSelectionMode();
        _loadFolderContent();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedItems.length} item(s) moved to trash'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error moving items to trash: $e')),
          );
        }
      }
    }
  }

  Widget _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text('${_selectedItems.length} selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _selectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedItems.isNotEmpty ? _deleteSelectedItems : null,
            tooltip: 'Move to Trash',
          ),
        ],
      );
    }

    return AppBar(
      title: Text(_currentFolder?.name ?? 'Home'),
      actions: [
        IconButton(
          icon: Icon(_viewMode == ViewMode.list ? Icons.grid_view : Icons.list),
          onPressed: _toggleViewMode,
          tooltip: 'Toggle View',
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortOptions,
          tooltip: 'Sort',
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            context.push('/search', extra: {'folderId': widget.folderId});
          },
          tooltip: 'Search',
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_open,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'This folder is empty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add content',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ContentGridItem(
            item: item,
            isSelected: _selectedItems.contains(item),
            onTap: () => _onItemTap(item),
            onLongPress: () => _onItemLongPress(item),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ContentListItem(
          item: item,
          isSelected: _selectedItems.contains(item),
          onTap: () => _onItemTap(item),
          onLongPress: () => _onItemLongPress(item),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: Column(
        children: [
          const BreadcrumbNavigation(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _showContentCreationDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}
