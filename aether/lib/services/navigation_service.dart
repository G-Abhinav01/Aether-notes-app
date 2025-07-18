import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/models/models.dart';

/// Service for managing app navigation and folder hierarchy
class NavigationService {
  /// Singleton instance
  static final NavigationService _instance = NavigationService._internal();
  
  factory NavigationService() => _instance;
  
  NavigationService._internal();
  
  /// Navigation history stack for folder navigation
  final List<String?> _folderNavigationStack = [null]; // Start with root folder (null)
  
  /// Current folder ID (null for root)
  String? get currentFolderId => _folderNavigationStack.last;
  
  /// Navigation history stack
  List<String?> get navigationStack => List.unmodifiable(_folderNavigationStack);
  
  /// Navigate to a folder
  void navigateToFolder(String? folderId) {
    if (folderId != currentFolderId) {
      _folderNavigationStack.add(folderId);
    }
  }
  
  /// Navigate back to the previous folder
  String? navigateBack() {
    if (_folderNavigationStack.length > 1) {
      _folderNavigationStack.removeLast();
      return currentFolderId;
    }
    return null; // Already at root
  }
  
  /// Navigate to the root folder
  void navigateToRoot() {
    _folderNavigationStack.clear();
    _folderNavigationStack.add(null);
  }
  
  /// Check if can navigate back
  bool canNavigateBack() {
    return _folderNavigationStack.length > 1;
  }
  
  /// Get breadcrumb path for current location
  List<String?> getBreadcrumbs() {
    return List.from(_folderNavigationStack);
  }
  
  /// Navigate to a specific position in the breadcrumb path
  void navigateToBreadcrumb(int index) {
    if (index >= 0 && index < _folderNavigationStack.length) {
      _folderNavigationStack.removeRange(index + 1, _folderNavigationStack.length);
    }
  }
  
  /// Reset navigation stack
  void resetNavigation() {
    _folderNavigationStack.clear();
    _folderNavigationStack.add(null);
  }
  
  /// Create a deep link for a content item
  String createDeepLink(ContentItem item) {
    switch (item.type) {
      case ContentType.folder:
        return '/folder/${item.id}';
      case ContentType.note:
        return '/note/${item.id}';
      case ContentType.task:
        return '/task/${item.id}';
      case ContentType.image:
        return '/image/${item.id}';
    }
  }
}