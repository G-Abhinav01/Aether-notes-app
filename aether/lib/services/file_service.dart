import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'package:aether/constants/app_constants.dart';

/// Service for managing file operations
class FileService {
  static final FileService _instance = FileService._internal();
  
  /// Singleton instance
  factory FileService() => _instance;
  
  FileService._internal();
  
  /// Get the app documents directory
  Future<Directory> get _appDir async {
    return await getApplicationDocumentsDirectory();
  }
  
  /// Get the images directory
  Future<Directory> get _imagesDir async {
    final Directory appDir = await _appDir;
    final Directory dir = Directory(join(appDir.path, AppConstants.imagesFolder));
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return dir;
  }
  
  /// Get the thumbnails directory
  Future<Directory> get _thumbnailsDir async {
    final Directory appDir = await _appDir;
    final Directory dir = Directory(join(appDir.path, AppConstants.thumbnailsFolder));
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return dir;
  }
  
  /// Get the exports directory
  Future<Directory> get _exportsDir async {
    final Directory appDir = await _appDir;
    final Directory dir = Directory(join(appDir.path, AppConstants.exportsFolder));
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return dir;
  }
  
  /// Get the backups directory
  Future<Directory> get _backupsDir async {
    final Directory appDir = await _appDir;
    final Directory dir = Directory(join(appDir.path, AppConstants.backupsFolder));
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return dir;
  }
  
  /// Save an image file
  Future<Map<String, String>> saveImage(File imageFile) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'img_$timestamp${extension(imageFile.path)}';
    
    // Save original image
    final Directory imagesDir = await _imagesDir;
    final String imagePath = join(imagesDir.path, fileName);
    final File savedImage = await imageFile.copy(imagePath);
    
    // Create and save thumbnail
    final String thumbnailName = 'thumb_$fileName';
    final Directory thumbnailsDir = await _thumbnailsDir;
    final String thumbnailPath = join(thumbnailsDir.path, thumbnailName);
    await _createThumbnail(imageFile.path, thumbnailPath);
    
    return {
      'imagePath': savedImage.path,
      'thumbnailPath': thumbnailPath,
    };
  }
  
  /// Create a thumbnail from an image
  Future<File> _createThumbnail(String imagePath, String thumbnailPath) async {
    // Read the image file
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    
    // Resize the image to thumbnail size (max 200x200)
    final img.Image thumbnail = img.copyResize(
      image,
      width: 200,
      height: (200 * image.height / image.width).round(),
    );
    
    // Save the thumbnail
    final File thumbnailFile = File(thumbnailPath);
    await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 85));
    
    return thumbnailFile;
  }
  
  /// Delete an image and its thumbnail
  Future<void> deleteImage(String imagePath, String thumbnailPath) async {
    final File imageFile = File(imagePath);
    final File thumbnailFile = File(thumbnailPath);
    
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    
    if (await thumbnailFile.exists()) {
      await thumbnailFile.delete();
    }
  }
  
  /// Create a backup file
  Future<File> createBackup(String content) async {
    final Directory backupsDir = await _backupsDir;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'backup_$timestamp.json';
    final String backupPath = join(backupsDir.path, fileName);
    
    final File backupFile = File(backupPath);
    return await backupFile.writeAsString(content);
  }
  
  /// List all backup files
  Future<List<File>> listBackups() async {
    final Directory backupsDir = await _backupsDir;
    final List<FileSystemEntity> entities = await backupsDir.list().toList();
    
    return entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();
  }
  
  /// Export content to a file
  Future<File> exportContent(String content, String fileName) async {
    final Directory exportsDir = await _exportsDir;
    final String exportPath = join(exportsDir.path, fileName);
    
    final File exportFile = File(exportPath);
    return await exportFile.writeAsString(content);
  }
  
  /// Get the size of all stored files
  Future<int> getTotalStorageSize() async {
    int totalSize = 0;
    
    // Add size of images
    final Directory imagesDir = await _imagesDir;
    if (await imagesDir.exists()) {
      final List<FileSystemEntity> imageFiles = await imagesDir.list().toList();
      for (final file in imageFiles) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    
    // Add size of thumbnails
    final Directory thumbnailsDir = await _thumbnailsDir;
    if (await thumbnailsDir.exists()) {
      final List<FileSystemEntity> thumbnailFiles = await thumbnailsDir.list().toList();
      for (final file in thumbnailFiles) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    
    // Add size of exports
    final Directory exportsDir = await _exportsDir;
    if (await exportsDir.exists()) {
      final List<FileSystemEntity> exportFiles = await exportsDir.list().toList();
      for (final file in exportFiles) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    
    // Add size of backups
    final Directory backupsDir = await _backupsDir;
    if (await backupsDir.exists()) {
      final List<FileSystemEntity> backupFiles = await backupsDir.list().toList();
      for (final file in backupFiles) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    
    return totalSize;
  }
  
  /// Clear all temporary files
  Future<void> clearTemporaryFiles() async {
    final Directory appDir = await _appDir;
    final Directory tempDir = Directory(join(appDir.path, 'temp'));
    
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }
}