import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aether/models/models.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/navigation_service.dart';

class ContentCreationDialog extends StatelessWidget {
  final String? parentFolderId;
  final VoidCallback? onContentCreated;

  const ContentCreationDialog({
    super.key,
    this.parentFolderId,
    this.onContentCreated,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ContentTypeOption(
            icon: Icons.folder,
            title: 'Folder',
            subtitle: 'Organize your content',
            onTap: () {
              Navigator.pop(context);
              _showFolderCreationDialog(context);
            },
          ),
          const SizedBox(height: 8),
          _ContentTypeOption(
            icon: Icons.note,
            title: 'Note',
            subtitle: 'Write and format text',
            onTap: () {
              Navigator.pop(context);
              _createNote(context);
            },
          ),
          const SizedBox(height: 8),
          _ContentTypeOption(
            icon: Icons.task_alt,
            title: 'Task',
            subtitle: 'Track your to-dos',
            onTap: () {
              Navigator.pop(context);
              _createTask(context);
            },
          ),
          const SizedBox(height: 8),
          _ContentTypeOption(
            icon: Icons.image,
            title: 'Image',
            subtitle: 'Add photos and pictures',
            onTap: () {
              Navigator.pop(context);
              _showImageSourceDialog(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _showFolderCreationDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Folder Name',
                hintText: 'Enter folder name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter folder description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await _createFolder(
                  context,
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      descriptionController.dispose();
    });
  }

  void _showImageSourceDialog(BuildContext context) {
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
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _createFolder(
    BuildContext context,
    String name,
    String description,
  ) async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      final folder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        parentId: parentFolderId,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      await contentRepository.createFolder(folder);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Folder "$name" created')));
        onContentCreated?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating folder: $e')));
      }
    }
  }

  Future<void> _createNote(BuildContext context) async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Untitled Note',
        content: '',
        format: NoteFormat.markdown,
        parentId: parentFolderId,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      await contentRepository.createNote(note);

      if (context.mounted) {
        final navigationService = Provider.of<NavigationService>(
          context,
          listen: false,
        );
        navigationService.navigateToItem(context, note);
        onContentCreated?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating note: $e')));
      }
    }
  }

  Future<void> _createTask(BuildContext context) async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'New Task',
        description: '',
        isCompleted: false,
        priority: TaskPriority.medium,
        parentId: parentFolderId,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      await contentRepository.createTask(task);

      if (context.mounted) {
        final navigationService = Provider.of<NavigationService>(
          context,
          listen: false,
        );
        navigationService.navigateToItem(context, task);
        onContentCreated?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating task: $e')));
      }
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        final contentRepository = Provider.of<ContentRepository>(
          context,
          listen: false,
        );

        // Create image item from picked file
        final imageItem = await contentRepository.createImageFromFile(
          image.path,
          parentId: parentFolderId,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image added successfully')),
          );

          final navigationService = Provider.of<NavigationService>(
            context,
            listen: false,
          );
          navigationService.navigateToItem(context, imageItem);
          onContentCreated?.call();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding image: $e')));
      }
    }
  }
}

class _ContentTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContentTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
