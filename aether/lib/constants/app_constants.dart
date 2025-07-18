// App-wide constants
class AppConstants {
  // Database
  static const String databaseName = 'aether_local.db';
  static const int databaseVersion = 1;
  
  // Storage
  static const String imagesFolder = 'images';
  static const String thumbnailsFolder = 'thumbnails';
  static const String exportsFolder = 'exports';
  static const String backupsFolder = 'backups';
  
  // UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double iconSize = 24.0;
  
  // Limits (Free Tier)
  static const int maxStorageGB = 1;
  static const int maxAIOperationsPerMonth = 10;
  static const int maxTemplates = 5;
}