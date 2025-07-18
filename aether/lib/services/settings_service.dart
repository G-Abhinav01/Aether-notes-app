import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aether/models/enums.dart';

/// Keys for settings
class SettingsKeys {
  static const String viewMode = 'view_mode';
  static const String sortOption = 'sort_option';
  static const String autoBackup = 'auto_backup';
  static const String backupFrequency = 'backup_frequency';
  static const String trashRetentionDays = 'trash_retention_days';
  static const String lastBackupTime = 'last_backup_time';
  static const String recentItemsLimit = 'recent_items_limit';
}

/// Service for managing app settings
class SettingsService {
  /// Singleton instance
  static final SettingsService _instance = SettingsService._internal();
  
  factory SettingsService() => _instance;
  
  SettingsService._internal();
  
  /// Default settings
  final Map<String, dynamic> _defaultSettings = {
    SettingsKeys.viewMode: ViewMode.list.index,
    SettingsKeys.sortOption: SortOption.nameAsc.index,
    SettingsKeys.autoBackup: false,
    SettingsKeys.backupFrequency: 7, // days
    SettingsKeys.trashRetentionDays: 30,
    SettingsKeys.recentItemsLimit: 20,
  };
  
  /// Current settings
  final Map<String, dynamic> _settings = {};
  
  /// Initialize settings
  Future<void> initialize() async {
    await loadSettings();
  }
  
  /// Load settings from shared preferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load all settings or use defaults
    for (final key in _defaultSettings.keys) {
      if (prefs.containsKey(key)) {
        _settings[key] = _getPreferenceValue(prefs, key);
      } else {
        _settings[key] = _defaultSettings[key];
      }
    }
    
    // Load any additional settings that might be stored
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (!_settings.containsKey(key)) {
        _settings[key] = _getPreferenceValue(prefs, key);
      }
    }
  }
  
  /// Helper method to get preference value based on type
  dynamic _getPreferenceValue(SharedPreferences prefs, String key) {
    if (prefs.containsKey(key)) {
      try {
        // Try to get as string first (could be JSON)
        final value = prefs.getString(key);
        if (value != null) {
          try {
            // Try to parse as JSON
            return jsonDecode(value);
          } catch (_) {
            // Not JSON, return as string
            return value;
          }
        }
      } catch (_) {
        // Not a string, try other types
      }
      
      // Try other types
      if (prefs.containsKey(key)) {
        if (prefs.getBool(key) != null) return prefs.getBool(key);
        if (prefs.getInt(key) != null) return prefs.getInt(key);
        if (prefs.getDouble(key) != null) return prefs.getDouble(key);
        if (prefs.getStringList(key) != null) return prefs.getStringList(key);
      }
    }
    
    // Return default if available
    return _defaultSettings[key];
  }
  
  /// Save a setting
  Future<void> setSetting(String key, dynamic value) async {
    _settings[key] = value;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Save based on type
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      // For complex objects, convert to JSON
      await prefs.setString(key, jsonEncode(value));
    }
  }
  
  /// Get a setting
  T? getSetting<T>(String key) {
    if (_settings.containsKey(key)) {
      final value = _settings[key];
      if (value is T) {
        return value;
      }
    }
    
    // Return default if available
    if (_defaultSettings.containsKey(key)) {
      final defaultValue = _defaultSettings[key];
      if (defaultValue is T) {
        return defaultValue;
      }
    }
    
    return null;
  }
  
  /// Get view mode
  ViewMode getViewMode() {
    final index = getSetting<int>(SettingsKeys.viewMode) ?? ViewMode.list.index;
    return ViewMode.values[index];
  }
  
  /// Set view mode
  Future<void> setViewMode(ViewMode mode) async {
    await setSetting(SettingsKeys.viewMode, mode.index);
  }
  
  /// Get sort option
  SortOption getSortOption() {
    final index = getSetting<int>(SettingsKeys.sortOption) ?? SortOption.nameAsc.index;
    return SortOption.values[index];
  }
  
  /// Set sort option
  Future<void> setSortOption(SortOption option) async {
    await setSetting(SettingsKeys.sortOption, option.index);
  }
  
  /// Get auto backup setting
  bool getAutoBackup() {
    return getSetting<bool>(SettingsKeys.autoBackup) ?? false;
  }
  
  /// Set auto backup setting
  Future<void> setAutoBackup(bool value) async {
    await setSetting(SettingsKeys.autoBackup, value);
  }
  
  /// Get backup frequency in days
  int getBackupFrequency() {
    return getSetting<int>(SettingsKeys.backupFrequency) ?? 7;
  }
  
  /// Set backup frequency in days
  Future<void> setBackupFrequency(int days) async {
    await setSetting(SettingsKeys.backupFrequency, days);
  }
  
  /// Get trash retention period in days
  int getTrashRetentionDays() {
    return getSetting<int>(SettingsKeys.trashRetentionDays) ?? 30;
  }
  
  /// Set trash retention period in days
  Future<void> setTrashRetentionDays(int days) async {
    await setSetting(SettingsKeys.trashRetentionDays, days);
  }
  
  /// Get last backup time
  DateTime? getLastBackupTime() {
    final timestamp = getSetting<int>(SettingsKeys.lastBackupTime);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  /// Set last backup time
  Future<void> setLastBackupTime(DateTime time) async {
    await setSetting(SettingsKeys.lastBackupTime, time.millisecondsSinceEpoch);
  }
  
  /// Get recent items limit
  int getRecentItemsLimit() {
    return getSetting<int>(SettingsKeys.recentItemsLimit) ?? 20;
  }
  
  /// Set recent items limit
  Future<void> setRecentItemsLimit(int limit) async {
    await setSetting(SettingsKeys.recentItemsLimit, limit);
  }
  
  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _settings.clear();
    _settings.addAll(_defaultSettings);
  }
}