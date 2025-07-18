import 'dart:io';
import 'dart:async';

import 'package:aether/models/models.dart';
import 'package:aether/services/storage_service.dart';
import 'package:aether/services/file_service.dart';
import 'package:image_picker/image_picker.dart';

/// Repository for managing content items
class ContentRepository {
  final StorageService _storageService = StorageService();
  final FileService _fileService = FileService();
  
  /// Singleton instance
  static final ContentRepository _instance = ContentRepository._internal();
  
  factory ContentRepository() => _instance;
  
  ContentRepository._internal();
  
  /// Create a new folder
  Future<Folder> createFolder({
    required String name,
    String? parentFolderId,
    String? colorTheme,
  }) async {
    final folder = Folder(
      name: name,
      parentFolderId: parentFolderId,
      colorTheme: colorTheme,
    );
    
    await _storageService.insertContentItem(folder);
    
    // If this folder has a parent, update the parent's child list
    if (parentFolderId != null) {
      final parent = await getFolder(parentFolderId);
      if (parent != null) {
        parent.addChild(folder.id);
        await _storageService.updateContentItem(parent);
      }
    }
    
    return folder;
  }
  
  /// Create a new note
  Future<Note> createNote({
    required String name,
    required String content,
    String? parentFolderId,
    NoteFormat format = NoteFormat.richText,
    List<String> tags = const [],
  }) async {
    final note = Note(
      name: name,
      content: content,
      parentFolderId: parentFolderId,
      format: format,
      tags: tags,
    );
    
    await _storageService.insertContentItem(note);
    
    // If this note has a parent, update the parent's child list
    if (parentFolderId != null) {
      final parent = await getFolder(parentFolderId);
      if (parent != null) {
        parent.addChild(note.id);
        await _storageService.updateContentItem(parent);
      }
    }
    
    return note;
  }
  
  /// Create a new task
  Future<Task> createTask({
    required String name,
    String description = '',
    String? parentFolderId,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
  }) async {
    final task = Task(
      name: name,
      description: description,
      parentFolderId: parentFolderId,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );
    
    await _storageService.insertContentItem(task);
    
    // If this task has a parent, update the parent's child list
    if (parentFolderId != null) {
      final parent = await getFolder(parentFolderId);
      if (parent != null) {
        parent.addChild(task.id);
        await _storageService.updateContentItem(parent);
      }
    }
    
    return task;
  }
  
  /// Create a new image item from a picked image
  Future<ImageItem?> createImageItem({
    required XFile pickedImage,
    required String name,
    String? parentFolderId,
  }) async {
    try {
      final File imageFile = File(pickedImage.path);
      final fileSize = await imageFile.length();
      
      // Save the image and create a thumbnail
      final Map<String, String> paths = await _fileService.saveImage(imageFile);
      
      // Extract basic image metadata
      final imageBytes = await imageFile.readAsBytes();
      final image = await decodeImageFromList(imageBytes);
      
      final imageMetadata = ImageMetadata(
        width: image.width,
        height: image.height,
        // Location and date taken would be extracted from EXIF in a real app
      );
      
      final imageItem = ImageItem(
        name: name.isNotEmpty ? name : pickedImage.name,
        parentFolderId: parentFolderId,
        filePath: paths['imagePath']!,
        thumbnailPath: paths['thumbnailPath']!,
        fileSize: fileSize,
        mimeType: pickedImage.mimeType ?? 'image/jpeg',
        metadata: imageMetadata,
      );
      
      await _storageService.insertContentItem(imageItem);
      
      // If this image has a parent, update the parent's child list
      if (parentFolderId != null) {
        final parent = await getFolder(parentFolderId);
        if (parent != null) {
          parent.addChild(imageItem.id);
          await _storageService.updateContentItem(parent);
        }
      }
      
      return imageItem;
    } catch (e) {
      print('Error creating image item: $e');
      return null;
    }
  }
  
  /// Get a content item by ID
  Future<ContentItem?> getContentItem(String id) async {
    return await _storageService.getContentItemById(id);
  }
  
  /// Get a folder by ID
  Future<Folder?> getFolder(String id) async {
    final item = await _storageService.getContentItemById(id);
    if (item is Folder) {
      return item;
    }
    return null;
  }
  
  /// Get a note by ID
  Future<Note?> getNote(String id) async {
    final item = await _storageService.getContentItemById(id);
    if (item is Note) {
      return item;
    }
    return null;
  }
  
  /// Get a task by ID
  Future<Task?> getTask(String id) async {
    final item = await _storageService.getContentItemById(id);
    if (item is Task) {
      return item;
    }
    return null;
  }
  
  /// Get an image item by ID
  Future<ImageItem?> getImageItem(String id) async {
    final item = await _storageService.getContentItemById(id);
    if (item is ImageItem) {
      return item;
    }
    return null;
  }
  
  /// Get all content items in a folder
  Future<List<ContentItem>> getItemsByFolder(String? folderId) async {
    return await _storageService.getContentItemsByFolder(folderId);
  }
  
  /// Get all folders in a parent folder
  Future<List<Folder>> getFoldersByParent(String? parentFolderId) async {
    final items = await _storageService.getContentItemsByFolder(parentFolderId);
    return items.whereType<Folder>().toList();
  }
  
  /// Get all notes in a folder
  Future<List<Note>> getNotesByFolder(String? folderId) async {
    final items = await _storageService.getContentItemsByFolder(folderId);
    return items.whereType<Note>().toList();
  }
  
  /// Get all tasks in a folder
  Future<List<Task>> getTasksByFolder(String? folderId) async {
    final items = await _storageService.getContentItemsByFolder(folderId);
    return items.whereType<Task>().toList();
  }
  
  /// Get all image items in a folder
  Future<List<ImageItem>> getImagesByFolder(String? folderId) async {
    final items = await _storageService.getContentItemsByFolder(folderId);
    return items.whereType<ImageItem>().toList();
  }
  
  /// Update a content item
  Future<void> updateContentItem(ContentItem item) async {
    await _storageService.updateContentItem(item);
  }
  
  /// Move a content item to a different folder
  Future<void> moveItem(String itemId, String? newParentFolderId) async {
    // Get the item to move
    final item = await _storageService.getContentItemById(itemId);
    if (item == null) return;
    
    // Get the old parent folder
    final oldParentFolderId = item.parentFolderId;
    if (oldParentFolderId != null) {
      final oldParent = await getFolder(oldParentFolderId);
      if (oldParent != null) {
        // Remove the item from the old parent's child list
        oldParent.removeChild(itemId);
        await _storageService.updateContentItem(oldParent);
      }
    }
    
    // Update the item's parent folder ID
    final updatedItem = _updateParentFolderId(item, newParentFolderId);
    await _storageService.updateContentItem(updatedItem);
    
    // Add the item to the new parent's child list
    if (newParentFolderId != null) {
      final newParent = await getFolder(newParentFolderId);
      if (newParent != null) {
        newParent.addChild(itemId);
        await _storageService.updateContentItem(newParent);
      }
    }
  }
  
  /// Helper method to update parent folder ID based on content type
  ContentItem _updateParentFolderId(ContentItem item, String? newParentFolderId) {
    switch (item.type) {
      case ContentType.folder:
        return (item as Folder).copyWith(parentFolderId: newParentFolderId);
      case ContentType.note:
        return (item as Note).copyWith(parentFolderId: newParentFolderId);
      case ContentType.task:
        return (item as Task).copyWith(parentFolderId: newParentFolderId);
      case ContentType.image:
        return (item as ImageItem).copyWith(parentFolderId: newParentFolderId);
    }
  }
  
  /// Delete a content item permanently
  Future<void> deleteItemPermanently(String itemId) async {
    // Get the item to delete
    final item = await _storageService.getContentItemById(itemId);
    if (item == null) return;
    
    // If it's a folder, delete all its children first
    if (item is Folder) {
      final children = await getItemsByFolder(item.id);
      for (final child in children) {
        await deleteItemPermanently(child.id);
      }
    }
    
    // If it's an image, delete the image files
    if (item is ImageItem) {
      await _fileService.deleteImage(item.filePath, item.thumbnailPath);
    }
    
    // Remove from parent's child list
    final parentFolderId = item.parentFolderId;
    if (parentFolderId != null) {
      final parent = await getFolder(parentFolderId);
      if (parent != null) {
        parent.removeChild(item.id);
        await _storageService.updateContentItem(parent);
      }
    }
    
    // Delete from database
    await _storageService.deleteContentItem(item.id);
  }
  
  /// Move a content item to trash (soft delete)
  Future<void> trashItem(String itemId) async {
    // Get the item to trash
    final item = await _storageService.getContentItemById(itemId);
    if (item == null) return;
    
    // If it's a folder, trash all its children too
    if (item is Folder) {
      final children = await getItemsByFolder(item.id);
      for (final child in children) {
        await trashItem(child.id);
      }
    }
    
    // Remove from parent's child list
    final parentFolderId = item.parentFolderId;
    if (parentFolderId != null) {
      final parent = await getFolder(parentFolderId);
      if (parent != null) {
        parent.removeChild(item.id);
        await _storageService.updateContentItem(parent);
      }
    }
    
    // Mark as deleted
    await _storageService.trashContentItem(item.id);
  }
  
  /// Restore a content item from trash
  Future<void> restoreItem(String itemId) async {
    // Get the item to restore
    final item = await _storageService.getContentItemById(itemId);
    if (item == null) return;
    
    // If it's a folder, restore all its children too
    if (item is Folder) {
      final children = await _getAllChildrenInTrash(item.id);
      for (final child in children) {
        await _storageService.restoreContentItem(child.id);
      }
    }
    
    // Restore the item
    await _storageService.restoreContentItem(item.id);
    
    // Add back to parent's child list if parent exists and is not in trash
    final parentFolderId = item.parentFolderId;
    if (parentFolderId != null) {
      final parent = await getFolder(parentFolderId);
      if (parent != null && !parent.isDeleted) {
        parent.addChild(item.id);
        await _storageService.updateContentItem(parent);
      }
    }
  }
  
  /// Helper method to get all children of a folder that are in trash
  Future<List<ContentItem>> _getAllChildrenInTrash(String folderId) async {
    final db = await _storageService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'parent_folder_id = ? AND is_deleted = 1',
      whereArgs: [folderId],
    );
    
    final List<ContentItem> items = [];
    for (final map in maps) {
      final item = await _storageService.getContentItemById(map['id'] as String);
      if (item != null) {
        items.add(item);
        
        // Recursively get children if it's a folder
        if (item is Folder) {
          final children = await _getAllChildrenInTrash(item.id);
          items.addAll(children);
        }
      }
    }
    
    return items;
  }
  
  /// Get all items in trash
  Future<List<ContentItem>> getTrashItems() async {
    return await _storageService.getDeletedContentItems();
  }
  
  /// Get recent notes
  Future<List<Note>> getRecentNotes({int limit = 20}) async {
    return await _storageService.getRecentNotes(limit: limit);
  }
  
  /// Get recent tasks
  Future<List<Task>> getRecentTasks({int limit = 20}) async {
    return await _storageService.getRecentTasks(limit: limit);
  }
  
  /// Toggle favorite status of a content item
  Future<void> toggleFavorite(String itemId) async {
    final item = await _storageService.getContentItemById(itemId);
    if (item == null) return;
    
    final updatedItem = _toggleFavoriteStatus(item);
    await _storageService.updateContentItem(updatedItem);
  }
  
  /// Helper method to toggle favorite status based on content type
  ContentItem _toggleFavoriteStatus(ContentItem item) {
    switch (item.type) {
      case ContentType.folder:
        return (item as Folder).copyWith(isFavorite: !item.isFavorite);
      case ContentType.note:
        return (item as Note).copyWith(isFavorite: !item.isFavorite);
      case ContentType.task:
        return (item as Task).copyWith(isFavorite: !item.isFavorite);
      case ContentType.image:
        return (item as ImageItem).copyWith(isFavorite: !item.isFavorite);
    }
  }
  
  /// Get all favorite items
  Future<List<ContentItem>> getFavoriteItems() async {
    return await _storageService.getFavoriteContentItems();
  }
  
  /// Search content items
  Future<List<ContentItem>> searchItems(String query, {String? folderId}) async {
    return await _storageService.searchContentItems(query, folderId: folderId);
  }
  
  /// Toggle completion status of a task
  Future<void> toggleTaskCompletion(String taskId) async {
    final task = await getTask(taskId);
    if (task == null) return;
    
    task.toggleCompletion();
    await _storageService.updateContentItem(task);
  }
  
  /// Export a content item
  Future<String?> exportItem(String itemId) async {
    final item = await _storageService.getContentItemById(itemId);
    if (item == null) return null;
    
    String content = '';
    String fileName = '';
    
    switch (item.type) {
      case ContentType.note:
        final note = item as Note;
        content = note.content;
        fileName = '${note.name}.txt';
        break;
      case ContentType.task:
        final task = item as Task;
        content = '${task.name}\n\n${task.description}';
        fileName = '${task.name}.txt';
        break;
      case ContentType.folder:
        // For folders, export a JSON representation
        content = item.toJson().toString();
        fileName = '${item.name}.json';
        break;
      case ContentType.image:
        // For images, we would copy the image file to exports directory
        // This is simplified for now
        return null;
    }
    
    final exportFile = await _fileService.exportContent(content, fileName);
    return exportFile.path;
  }
}