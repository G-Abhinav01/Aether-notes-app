import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:aether/constants/app_constants.dart';
import 'package:aether/models/models.dart';

/// Service for managing local SQLite database operations
class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  /// Singleton instance
  factory StorageService() => _instance;
  
  StorageService._internal();
  
  /// Database instance
  Database? _database;
  
  /// Get the database instance, initializing if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize the database
  Future<Database> _initDatabase() async {
    // Get the documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConstants.databaseName);
    
    // Open/create the database
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }
  
  /// Create the database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create content_items table
    await db.execute('''
      CREATE TABLE content_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        parent_folder_id TEXT,
        created_at INTEGER NOT NULL,
        modified_at INTEGER NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        content_data TEXT,
        search_content TEXT,
        FOREIGN KEY (parent_folder_id) REFERENCES content_items(id)
      )
    ''');
    
    // Create app_settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    // Create search_index table
    await db.execute('''
      CREATE TABLE search_index (
        content_id TEXT,
        term TEXT,
        frequency INTEGER,
        PRIMARY KEY (content_id, term),
        FOREIGN KEY (content_id) REFERENCES content_items(id)
      )
    ''');
    
    // Create indexes for performance
    await db.execute('CREATE INDEX idx_content_parent ON content_items(parent_folder_id)');
    await db.execute('CREATE INDEX idx_content_type ON content_items(type)');
    await db.execute('CREATE INDEX idx_content_favorite ON content_items(is_favorite)');
    await db.execute('CREATE INDEX idx_content_deleted ON content_items(is_deleted)');
    await db.execute('CREATE INDEX idx_content_modified ON content_items(modified_at)');
    await db.execute('CREATE INDEX idx_search_term ON search_index(term)');
  }
  
  /// Upgrade the database schema
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE content_items ADD COLUMN new_column TEXT');
    }
  }
  
  /// Insert a content item into the database
  Future<String> insertContentItem(ContentItem item) async {
    final db = await database;
    
    // Convert the item to a map
    Map<String, dynamic> baseMap = {
      'id': item.id,
      'name': item.name,
      'type': item.type.index,
      'parent_folder_id': item.parentFolderId,
      'created_at': item.createdAt.millisecondsSinceEpoch,
      'modified_at': item.modifiedAt.millisecondsSinceEpoch,
      'is_favorite': item.isFavorite ? 1 : 0,
      'is_deleted': item.isDeleted ? 1 : 0,
    };
    
    // Add type-specific data as JSON
    Map<String, dynamic> contentData = {};
    
    switch (item.type) {
      case ContentType.folder:
        final folder = item as Folder;
        contentData = {
          'child_ids': folder.childIds,
          'color_theme': folder.colorTheme,
        };
        break;
      case ContentType.note:
        final note = item as Note;
        contentData = {
          'content': note.content,
          'plain_text_content': note.plainTextContent,
          'tags': note.tags,
          'format': note.format.index,
        };
        // Update search index
        await _updateSearchIndex(db, note.id, note.plainTextContent);
        break;
      case ContentType.task:
        final task = item as Task;
        contentData = {
          'description': task.description,
          'is_completed': task.isCompleted,
          'due_date': task.dueDate?.millisecondsSinceEpoch,
          'priority': task.priority.index,
          'tags': task.tags,
        };
        // Update search index
        await _updateSearchIndex(db, task.id, '${task.name} ${task.description}');
        break;
      case ContentType.image:
        final image = item as ImageItem;
        contentData = {
          'file_path': image.filePath,
          'thumbnail_path': image.thumbnailPath,
          'file_size': image.fileSize,
          'mime_type': image.mimeType,
          'metadata': {
            'width': image.metadata.width,
            'height': image.metadata.height,
            'location': image.metadata.location,
            'date_taken': image.metadata.dateTaken?.millisecondsSinceEpoch,
          },
        };
        break;
    }
    
    // Add content data as JSON string
    baseMap['content_data'] = jsonEncode(contentData);
    
    // Add search content
    switch (item.type) {
      case ContentType.note:
        baseMap['search_content'] = (item as Note).plainTextContent;
        break;
      case ContentType.task:
        baseMap['search_content'] = '${item.name} ${(item as Task).description}';
        break;
      default:
        baseMap['search_content'] = item.name;
        break;
    }
    
    // Insert into database
    await db.insert(
      'content_items',
      baseMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return item.id;
  }
  
  /// Update a content item in the database
  Future<int> updateContentItem(ContentItem item) async {
    final db = await database;
    
    // Convert the item to a map (similar to insert)
    Map<String, dynamic> baseMap = {
      'name': item.name,
      'parent_folder_id': item.parentFolderId,
      'modified_at': item.modifiedAt.millisecondsSinceEpoch,
      'is_favorite': item.isFavorite ? 1 : 0,
      'is_deleted': item.isDeleted ? 1 : 0,
    };
    
    // Add type-specific data as JSON (similar to insert)
    Map<String, dynamic> contentData = {};
    
    switch (item.type) {
      case ContentType.folder:
        final folder = item as Folder;
        contentData = {
          'child_ids': folder.childIds,
          'color_theme': folder.colorTheme,
        };
        break;
      case ContentType.note:
        final note = item as Note;
        contentData = {
          'content': note.content,
          'plain_text_content': note.plainTextContent,
          'tags': note.tags,
          'format': note.format.index,
        };
        // Update search index
        await _updateSearchIndex(db, note.id, note.plainTextContent);
        break;
      case ContentType.task:
        final task = item as Task;
        contentData = {
          'description': task.description,
          'is_completed': task.isCompleted,
          'due_date': task.dueDate?.millisecondsSinceEpoch,
          'priority': task.priority.index,
          'tags': task.tags,
        };
        // Update search index
        await _updateSearchIndex(db, task.id, '${task.name} ${task.description}');
        break;
      case ContentType.image:
        final image = item as ImageItem;
        contentData = {
          'file_path': image.filePath,
          'thumbnail_path': image.thumbnailPath,
          'file_size': image.fileSize,
          'mime_type': image.mimeType,
          'metadata': {
            'width': image.metadata.width,
            'height': image.metadata.height,
            'location': image.metadata.location,
            'date_taken': image.metadata.dateTaken?.millisecondsSinceEpoch,
          },
        };
        break;
    }
    
    // Add content data as JSON string
    baseMap['content_data'] = jsonEncode(contentData);
    
    // Add search content
    switch (item.type) {
      case ContentType.note:
        baseMap['search_content'] = (item as Note).plainTextContent;
        break;
      case ContentType.task:
        baseMap['search_content'] = '${item.name} ${(item as Task).description}';
        break;
      default:
        baseMap['search_content'] = item.name;
        break;
    }
    
    // Update in database
    return await db.update(
      'content_items',
      baseMap,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
  
  /// Delete a content item from the database
  Future<int> deleteContentItem(String id) async {
    final db = await database;
    
    // Delete from search index
    await db.delete(
      'search_index',
      where: 'content_id = ?',
      whereArgs: [id],
    );
    
    // Delete from content_items
    return await db.delete(
      'content_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Soft delete a content item (move to trash)
  Future<int> trashContentItem(String id) async {
    final db = await database;
    
    return await db.update(
      'content_items',
      {'is_deleted': 1, 'modified_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Restore a content item from trash
  Future<int> restoreContentItem(String id) async {
    final db = await database;
    
    return await db.update(
      'content_items',
      {'is_deleted': 0, 'modified_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get a content item by ID
  Future<ContentItem?> getContentItemById(String id) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return _mapToContentItem(maps.first);
  }
  
  /// Get all content items in a folder
  Future<List<ContentItem>> getContentItemsByFolder(String? folderId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'parent_folder_id ${folderId == null ? "IS NULL" : "= ?"} AND is_deleted = 0',
      whereArgs: folderId != null ? [folderId] : [],
      orderBy: 'type ASC, name ASC',
    );
    
    return List.generate(maps.length, (i) {
      return _mapToContentItem(maps[i])!;
    });
  }
  
  /// Get all deleted content items (trash)
  Future<List<ContentItem>> getDeletedContentItems() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'is_deleted = 1',
      orderBy: 'modified_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return _mapToContentItem(maps[i])!;
    });
  }
  
  /// Get recent notes
  Future<List<Note>> getRecentNotes({int limit = 20}) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'type = ? AND is_deleted = 0',
      whereArgs: [ContentType.note.index],
      orderBy: 'modified_at DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return _mapToContentItem(maps[i])! as Note;
    });
  }
  
  /// Get recent tasks
  Future<List<Task>> getRecentTasks({int limit = 20}) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'type = ? AND is_deleted = 0',
      whereArgs: [ContentType.task.index],
      orderBy: 'modified_at DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return _mapToContentItem(maps[i])! as Task;
    });
  }
  
  /// Get favorite content items
  Future<List<ContentItem>> getFavoriteContentItems() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'is_favorite = 1 AND is_deleted = 0',
      orderBy: 'type ASC, name ASC',
    );
    
    return List.generate(maps.length, (i) {
      return _mapToContentItem(maps[i])!;
    });
  }
  
  /// Search content items
  Future<List<ContentItem>> searchContentItems(String query, {String? folderId}) async {
    final db = await database;
    
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];
    
    if (folderId != null) {
      whereClause += ' AND parent_folder_id = ?';
      whereArgs.add(folderId);
    }
    
    if (query.startsWith('#')) {
      // Search only in names
      whereClause += ' AND name LIKE ?';
      whereArgs.add('%${query.substring(1)}%');
    } else {
      // Search in names and content
      whereClause += ' AND (name LIKE ? OR search_content LIKE ?)';
      whereArgs.add('%$query%');
      whereArgs.add('%$query%');
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'modified_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return _mapToContentItem(maps[i])!;
    });
  }
  
  /// Update the search index for a content item
  Future<void> _updateSearchIndex(Database db, String contentId, String content) async {
    // Delete existing index entries for this content
    await db.delete(
      'search_index',
      where: 'content_id = ?',
      whereArgs: [contentId],
    );
    
    // Tokenize the content
    final List<String> words = content
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && word.length > 2)
        .toList();
    
    // Count word frequencies
    final Map<String, int> wordFrequencies = {};
    for (final word in words) {
      wordFrequencies[word] = (wordFrequencies[word] ?? 0) + 1;
    }
    
    // Insert into search index
    final Batch batch = db.batch();
    wordFrequencies.forEach((word, frequency) {
      batch.insert(
        'search_index',
        {
          'content_id': contentId,
          'term': word,
          'frequency': frequency,
        },
      );
    });
    
    await batch.commit(noResult: true);
  }
  
  /// Convert a database map to a ContentItem
  ContentItem? _mapToContentItem(Map<String, dynamic> map) {
    final ContentType type = ContentType.values[map['type'] as int];
    final DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int);
    final DateTime modifiedAt = DateTime.fromMillisecondsSinceEpoch(map['modified_at'] as int);
    final bool isFavorite = (map['is_favorite'] as int) == 1;
    final bool isDeleted = (map['is_deleted'] as int) == 1;
    
    // Parse content_data JSON
    Map<String, dynamic> contentData = {};
    if (map['content_data'] != null && (map['content_data'] as String).isNotEmpty) {
      try {
        contentData = Map<String, dynamic>.from(
          jsonDecode(map['content_data'] as String)
        );
      } catch (e) {
        // Handle JSON parsing error
        contentData = {};
      }
    }
    
    switch (type) {
      case ContentType.folder:
        return Folder(
          id: map['id'] as String,
          name: map['name'] as String,
          parentFolderId: map['parent_folder_id'] as String?,
          createdAt: createdAt,
          modifiedAt: modifiedAt,
          isFavorite: isFavorite,
          isDeleted: isDeleted,
          childIds: contentData['child_ids'] != null 
              ? List<String>.from(contentData['child_ids']) 
              : [],
          colorTheme: contentData['color_theme'] as String?,
        );
      case ContentType.note:
        return Note(
          id: map['id'] as String,
          name: map['name'] as String,
          parentFolderId: map['parent_folder_id'] as String?,
          createdAt: createdAt,
          modifiedAt: modifiedAt,
          isFavorite: isFavorite,
          isDeleted: isDeleted,
          content: contentData['content'] as String? ?? '',
          plainTextContent: contentData['plain_text_content'] as String? ?? '',
          tags: contentData['tags'] != null 
              ? List<String>.from(contentData['tags']) 
              : [],
          format: contentData['format'] != null 
              ? NoteFormat.values[contentData['format'] as int]
              : NoteFormat.richText,
        );
      case ContentType.task:
        return Task(
          id: map['id'] as String,
          name: map['name'] as String,
          parentFolderId: map['parent_folder_id'] as String?,
          createdAt: createdAt,
          modifiedAt: modifiedAt,
          isFavorite: isFavorite,
          isDeleted: isDeleted,
          description: contentData['description'] as String? ?? '',
          isCompleted: contentData['is_completed'] as bool? ?? false,
          dueDate: contentData['due_date'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(contentData['due_date'] as int)
              : null,
          priority: contentData['priority'] != null 
              ? TaskPriority.values[contentData['priority'] as int]
              : TaskPriority.medium,
          tags: contentData['tags'] != null 
              ? List<String>.from(contentData['tags']) 
              : [],
        );
      case ContentType.image:
        final metadataMap = contentData['metadata'] as Map<String, dynamic>? ?? {};
        return ImageItem(
          id: map['id'] as String,
          name: map['name'] as String,
          parentFolderId: map['parent_folder_id'] as String?,
          createdAt: createdAt,
          modifiedAt: modifiedAt,
          isFavorite: isFavorite,
          isDeleted: isDeleted,
          filePath: contentData['file_path'] as String? ?? '',
          thumbnailPath: contentData['thumbnail_path'] as String? ?? '',
          fileSize: contentData['file_size'] as int? ?? 0,
          mimeType: contentData['mime_type'] as String? ?? '',
          metadata: ImageMetadata(
            width: metadataMap['width'] as int? ?? 0,
            height: metadataMap['height'] as int? ?? 0,
            location: metadataMap['location'] as String?,
            dateTaken: metadataMap['date_taken'] != null 
                ? DateTime.fromMillisecondsSinceEpoch(metadataMap['date_taken'] as int)
                : null,
          ),
        );
    }
  }
  
  /// Save an app setting
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    
    await db.insert(
      'app_settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get an app setting
  Future<String?> getSetting(String key) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return maps.first['value'] as String;
  }
  
  /// Get all app settings
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query('app_settings');
    
    final Map<String, String> settings = {};
    for (final map in maps) {
      settings[map['key'] as String] = map['value'] as String;
    }
    
    return settings;
  }
  
  /// Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}