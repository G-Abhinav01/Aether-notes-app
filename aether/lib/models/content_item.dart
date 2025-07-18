import 'package:uuid/uuid.dart';
import 'enums.dart';

/// Abstract base class for all content items (folders, notes, tasks, images)
abstract class ContentItem {
  /// Unique identifier for the content item
  final String id;
  
  /// Name/title of the content item
  String name;
  
  /// ID of the parent folder (null for root items)
  String? parentFolderId;
  
  /// Creation timestamp
  final DateTime createdAt;
  
  /// Last modification timestamp
  DateTime modifiedAt;
  
  /// Whether the item is marked as favorite
  bool isFavorite;
  
  /// Whether the item is in trash (soft deleted)
  bool isDeleted;
  
  /// Type of content item
  final ContentType type;
  
  ContentItem({
    String? id,
    required this.name,
    this.parentFolderId,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.isFavorite = false,
    this.isDeleted = false,
    required this.type,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    modifiedAt = modifiedAt ?? DateTime.now();
  
  /// Convert to JSON map
  Map<String, dynamic> toJson();
  
  /// Create a copy of the content item with updated fields
  ContentItem copyWith();
  
  /// Validate the content item
  bool validate() {
    return name.isNotEmpty;
  }
}