import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/services/settings_service.dart';
import 'package:aether/models/models.dart';
import 'package:aether/widgets/breadcrumb_navigation.dart';
import 'package:image_picker/image_picker.dart';

class FolderScreen extends StatefulWidget {
  final String? folderId;
  
  const FolderScreen({super.key, this.folderId});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  @override
  void initState() {
    super.initState();
    // Update navigation service with current folder
    Provider.of<NavigationService>(context, listen: false).navigateToFolder(widget.folderId);
  }
  
  @override
  Widget build(BuildContext context) {
    final contentRepository = Provider.of<ContentRepository>(context);
    final navigationService = Provider.of<NavigationService>(context);
    final settingsService = Provider.of<SettingsService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Folder?>(
          future: widget.folderId != null ? contentRepository.getFolder(widget.folderId!) : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            
            if (snapshot.hasData && snapshot.data != null) {
              return Text(snapshot.data!.name);
            }
            
            return const Text('Folder');
          },
        ),
        leading: navigationService.canNavigateBack()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  final previousFolderId = navigationService.navigateBack();
                  Navigator.of(context).pop();
                },
              )
            : null,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          
          // View toggle button
          IconButton(
            icon: Icon(
              settingsService.getViewMode() == ViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            onPressed: () async {
              await settingsService.setViewMode(
                settingsService.getViewMode() == ViewMode.list
                    ? ViewMode.grid
                    : ViewMode.list,
              );
              setState(() {});
            },
          ),
          
          // Sort button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptionsDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: const BreadcrumbNavigation(),
          ),
          
          // Folder contents
          Expanded(
            child: FolderContentsView(folderId: widget.folderId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateContentDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showSortOptionsDialog(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    final currentSortOption = settingsService.getSortOption();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Name (A-Z)'),
              leading: Radio<SortOption>(
                value: SortOption.nameAsc,
                groupValue: currentSortOption,
                onChanged: (value) async {
                  await settingsService.setSortOption(value!);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ),
            ListTile(
              title: const Text('Name (Z-A)'),
              leading: Radio<SortOption>(
                value: SortOption.nameDesc,
                groupValue: currentSortOption,
                onChanged: (value) async {
                  await settingsService.setSortOption(value!);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ),
            ListTile(
              title: const Text('Date Modified (Newest)'),
              leading: Radio<SortOption>(
                value: SortOption.dateModifiedDesc,
                groupValue: currentSortOption,
                onChanged: (value) async {
                  await settingsService.setSortOption(value!);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ),
            ListTile(
              title: const Text('Date Modified (Oldest)'),
              leading: Radio<SortOption>(
                value: SortOption.dateModifiedAsc,
                groupValue: currentSortOption,
                onChanged: (value) async {
                  await settingsService.setSortOption(value!);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ),
            ListTile(
              title: const Text('Type'),
              leading: Radio<SortOption>(
                value: SortOption.typeAsc,
                groupValue: currentSortOption,
                onChanged: (value) async {
                  await settingsService.setSortOption(value!);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Folder'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Note'),
              onTap: () {
                Navigator.pop(context);
                _showCreateNoteDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Task'),
              onTap: () {
                Navigator.pop(context);
                _showCreateTaskDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                _showImagePickerDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            hintText: 'Enter folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final contentRepository = Provider.of<ContentRepository>(context, listen: false);
                final navigationService = Provider.of<NavigationService>(context, listen: false);
                
                await contentRepository.createFolder(
                  name: nameController.text,
                  parentFolderId: widget.folderId,
                );
                
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((_) => nameController.dispose());
  }
  
  void _showCreateNoteDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Note'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Note Title',
            hintText: 'Enter note title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final contentRepository = Provider.of<ContentRepository>(context, listen: false);
                
                final note = await contentRepository.createNote(
                  name: nameController.text,
                  content: '',
                  parentFolderId: widget.folderId,
                );
                
                Navigator.pop(context);
                
                // Navigate to the note editor
                if (context.mounted) {
                  context.push('/note/${note.id}');
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((_) => nameController.dispose());
  }
  
  void _showCreateTaskDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Task'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Task Title',
            hintText: 'Enter task title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final contentRepository = Provider.of<ContentRepository>(context, listen: false);
                
                final task = await contentRepository.createTask(
                  name: nameController.text,
                  parentFolderId: widget.folderId,
                );
                
                Navigator.pop(context);
                
                // Navigate to the task editor
                if (context.mounted) {
                  context.push('/task/${task.id}');
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((_) => nameController.dispose());
  }
  
  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);
    
    if (pickedImage != null && context.mounted) {
      // Show dialog to name the image
      final TextEditingController nameController = TextEditingController(
        text: pickedImage.name,
      );
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Image Name'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Image Name',
              hintText: 'Enter image name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final contentRepository = Provider.of<ContentRepository>(context, listen: false);
                  
                  final imageItem = await contentRepository.createImageItem(
                    pickedImage: pickedImage,
                    name: nameController.text,
                    parentFolderId: widget.folderId,
                  );
                  
                  Navigator.pop(context);
                  
                  // Navigate to the image viewer if image was created successfully
                  if (imageItem != null && context.mounted) {
                    context.push('/image/${imageItem.id}');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ).then((_) => nameController.dispose());
    }
  }
}

class FolderContentsView extends StatefulWidget {
  final String? folderId;
  
  const FolderContentsView({super.key, this.folderId});

  @override
  State<FolderContentsView> createState() => _FolderContentsViewState();
}

class _FolderContentsViewState extends State<FolderContentsView> {
  @override
  Widget build(BuildContext context) {
    final contentRepository = Provider.of<ContentRepository>(context);
    final settingsService = Provider.of<SettingsService>(context);
    final viewMode = settingsService.getViewMode();
    
    return FutureBuilder<List<ContentItem>>(
      future: contentRepository.getItemsByFolder(widget.folderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final items = snapshot.data ?? [];
        
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('This folder is empty'),
                SizedBox(height: 8),
                Text('Tap + to create content', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        
        // Sort items based on settings
        _sortItems(items, settingsService.getSortOption());
        
        // Display items based on view mode
        return viewMode == ViewMode.list
            ? _buildListView(items)
            : _buildGridView(items);
      },
    );
  }
  
  Widget _buildListView(List<ContentItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildContentListItem(item);
      },
    );
  }
  
  Widget _buildGridView(List<ContentItem> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildContentGridItem(item);
      },
    );
  }
  
  Widget _buildContentListItem(ContentItem item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(
        _formatDate(item.modifiedAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      leading: _getIconForContentType(item.type),
      onTap: () => _handleItemTap(item),
      trailing: item.isFavorite ? const Icon(Icons.star, color: Colors.amber) : null,
    );
  }
  
  Widget _buildContentGridItem(ContentItem item) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _handleItemTap(item),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                _getIconForContentType(item.type, size: 48),
                if (item.isFavorite)
                  const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getIconForContentType(ContentType type, {double size = 24}) {
    switch (type) {
      case ContentType.folder:
        return Icon(Icons.folder, size: size);
      case ContentType.note:
        return Icon(Icons.description, size: size);
      case ContentType.task:
        return Icon(Icons.check_circle, size: size);
      case ContentType.image:
        return Icon(Icons.image, size: size);
    }
  }
  
  void _handleItemTap(ContentItem item) {
    switch (item.type) {
      case ContentType.folder:
        // Navigate to folder
        Provider.of<NavigationService>(context, listen: false).navigateToFolder(item.id);
        context.push('/folder/${item.id}');
        break;
      case ContentType.note:
        // Navigate to note editor
        context.push('/note/${item.id}');
        break;
      case ContentType.task:
        // Navigate to task editor
        context.push('/task/${item.id}');
        break;
      case ContentType.image:
        // Navigate to image viewer
        context.push('/image/${item.id}');
        break;
    }
  }
  
  void _sortItems(List<ContentItem> items, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.nameAsc:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.dateCreatedAsc:
        items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.dateCreatedDesc:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateModifiedAsc:
        items.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
        break;
      case SortOption.dateModifiedDesc:
        items.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        break;
      case SortOption.typeAsc:
        items.sort((a, b) => a.type.index.compareTo(b.type.index));
        break;
      case SortOption.typeDesc:
        items.sort((a, b) => b.type.index.compareTo(a.type.index));
        break;
    }
    
    // Always put folders first
    items.sort((a, b) {
      if (a.type == ContentType.folder && b.type != ContentType.folder) {
        return -1;
      } else if (a.type != ContentType.folder && b.type == ContentType.folder) {
        return 1;
      }
      return 0;
    });
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}