import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:aether/services/storage_service.dart';
import 'package:aether/models/models.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      storageService = StorageService();
    });

    tearDown(() async {
      await storageService.close();
    });

    test('should create and retrieve a folder', () async {
      // Create a test folder
      final folder = Folder(
        name: 'Test Folder',
        colorTheme: 'blue',
      );

      // Insert the folder
      final insertedId = await storageService.insertContentItem(folder);
      expect(insertedId, equals(folder.id));

      // Retrieve the folder
      final retrievedFolder = await storageService.getContentItemById(folder.id);
      expect(retrievedFolder, isNotNull);
      expect(retrievedFolder!.name, equals('Test Folder'));
      expect((retrievedFolder as Folder).colorTheme, equals('blue'));
    });

    test('should create and retrieve a note', () async {
      // Create a test note
      final note = Note(
        name: 'Test Note',
        content: 'This is a test note content',
        tags: ['test', 'flutter'],
        format: NoteFormat.richText,
      );

      // Insert the note
      final insertedId = await storageService.insertContentItem(note);
      expect(insertedId, equals(note.id));

      // Retrieve the note
      final retrievedNote = await storageService.getContentItemById(note.id);
      expect(retrievedNote, isNotNull);
      expect(retrievedNote!.name, equals('Test Note'));
      expect((retrievedNote as Note).content, equals('This is a test note content'));
      expect(retrievedNote.tags, containsAll(['test', 'flutter']));
    });

    test('should create and retrieve a task', () async {
      // Create a test task
      final task = Task(
        name: 'Test Task',
        description: 'This is a test task',
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 7)),
      );

      // Insert the task
      final insertedId = await storageService.insertContentItem(task);
      expect(insertedId, equals(task.id));

      // Retrieve the task
      final retrievedTask = await storageService.getContentItemById(task.id);
      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.name, equals('Test Task'));
      expect((retrievedTask as Task).description, equals('This is a test task'));
      expect(retrievedTask.priority, equals(TaskPriority.high));
    });

    test('should handle folder hierarchy', () async {
      // Create parent folder
      final parentFolder = Folder(name: 'Parent Folder');
      await storageService.insertContentItem(parentFolder);

      // Create child folder
      final childFolder = Folder(
        name: 'Child Folder',
        parentFolderId: parentFolder.id,
      );
      await storageService.insertContentItem(childFolder);

      // Create note in child folder
      final note = Note(
        name: 'Child Note',
        content: 'Note in child folder',
        parentFolderId: childFolder.id,
      );
      await storageService.insertContentItem(note);

      // Get items in parent folder
      final parentItems = await storageService.getContentItemsByFolder(parentFolder.id);
      expect(parentItems.length, equals(1));
      expect(parentItems.first.name, equals('Child Folder'));

      // Get items in child folder
      final childItems = await storageService.getContentItemsByFolder(childFolder.id);
      expect(childItems.length, equals(1));
      expect(childItems.first.name, equals('Child Note'));
    });

    test('should handle soft delete (trash)', () async {
      // Create a note
      final note = Note(name: 'Test Note', content: 'Test content');
      await storageService.insertContentItem(note);

      // Verify note exists
      final retrievedNote = await storageService.getContentItemById(note.id);
      expect(retrievedNote, isNotNull);

      // Soft delete the note
      await storageService.trashContentItem(note.id);

      // Verify note is not in regular queries
      final rootItems = await storageService.getContentItemsByFolder(null);
      expect(rootItems.any((item) => item.id == note.id), isFalse);

      // Verify note is in trash
      final trashedItems = await storageService.getDeletedContentItems();
      expect(trashedItems.any((item) => item.id == note.id), isTrue);

      // Restore the note
      await storageService.restoreContentItem(note.id);

      // Verify note is back in regular queries
      final restoredItems = await storageService.getContentItemsByFolder(null);
      expect(restoredItems.any((item) => item.id == note.id), isTrue);
    });

    test('should handle search functionality', () async {
      // Create test content
      final note1 = Note(name: 'Flutter Tutorial', content: 'Learn Flutter development');
      final note2 = Note(name: 'Dart Basics', content: 'Understanding Dart language');
      final task = Task(name: 'Flutter Project', description: 'Build a Flutter app');

      await storageService.insertContentItem(note1);
      await storageService.insertContentItem(note2);
      await storageService.insertContentItem(task);

      // Search for 'Flutter'
      final flutterResults = await storageService.searchContentItems('Flutter');
      expect(flutterResults.length, equals(2));
      expect(flutterResults.any((item) => item.name == 'Flutter Tutorial'), isTrue);
      expect(flutterResults.any((item) => item.name == 'Flutter Project'), isTrue);

      // Search for 'Dart'
      final dartResults = await storageService.searchContentItems('Dart');
      expect(dartResults.length, equals(1));
      expect(dartResults.first.name, equals('Dart Basics'));

      // Search with # prefix (name only)
      final nameOnlyResults = await storageService.searchContentItems('#Tutorial');
      expect(nameOnlyResults.length, equals(1));
      expect(nameOnlyResults.first.name, equals('Flutter Tutorial'));
    });

    test('should handle favorites', () async {
      // Create content items
      final note = Note(name: 'Important Note', content: 'Very important');
      final task = Task(name: 'Important Task', description: 'Must do');

      await storageService.insertContentItem(note);
      await storageService.insertContentItem(task);

      // Mark as favorites
      note.isFavorite = true;
      task.isFavorite = true;
      await storageService.updateContentItem(note);
      await storageService.updateContentItem(task);

      // Get favorites
      final favorites = await storageService.getFavoriteContentItems();
      expect(favorites.length, equals(2));
      expect(favorites.every((item) => item.isFavorite), isTrue);
    });

    test('should handle recent items', () async {
      // Create notes with different timestamps
      final note1 = Note(name: 'Old Note', content: 'Old content');
      final note2 = Note(name: 'New Note', content: 'New content');
      
      await storageService.insertContentItem(note1);
      await Future.delayed(const Duration(milliseconds: 10));
      await storageService.insertContentItem(note2);

      // Get recent notes
      final recentNotes = await storageService.getRecentNotes(limit: 10);
      expect(recentNotes.length, equals(2));
      expect(recentNotes.first.name, equals('New Note')); // Most recent first
    });

    test('should handle app settings', () async {
      // Save settings
      await storageService.saveSetting('theme', 'dark');
      await storageService.saveSetting('language', 'en');

      // Retrieve individual setting
      final theme = await storageService.getSetting('theme');
      expect(theme, equals('dark'));

      // Retrieve all settings
      final allSettings = await storageService.getAllSettings();
      expect(allSettings['theme'], equals('dark'));
      expect(allSettings['language'], equals('en'));
    });
  });
}