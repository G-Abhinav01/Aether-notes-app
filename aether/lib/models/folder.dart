import 'package:json_annotation/json_annotation.dart';
import 'content_item.dart';
import 'enums.dart';

part 'folder.g.dart';

/// Folder model for organizing content items
@JsonSerializable(explicitToJson: true)
class Folder extends ContentItem {
  /// List of child item IDs
  List<String> childIds;
  
  /// Count of items in the folder
  @JsonKey(ignore: true)
  int itemCount;
  
  /// Color theme for the folder
  String? colorTheme;
  
  Folder({
    super.id,
    required super.name,
    super.parentFolderId,
    super.createdAt,
    super.modifiedAt,
    super.isFavorite,
    super.isDeleted,
    this.childIds = const [],
    this.itemCount = 0,
    this.colorTheme,
  }) : super(
    type: ContentType.folder,
  );
  
  /// Create from JSON
  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$FolderToJson(this);
  
  @override
  Folder copyWith({
    String? name,
    String? parentFolderId,
    DateTime? modifiedAt,
    bool? isFavorite,
    bool? isDeleted,
    List<String>? childIds,
    int? itemCount,
    String? colorTheme,
  }) {
    return Folder(
      id: id,
      name: name ?? this.name,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      childIds: childIds ?? List.from(this.childIds),
      itemCount: itemCount ?? this.itemCount,
      colorTheme: colorTheme ?? this.colorTheme,
    );
  }
  
  
  /// Add a child item to the folder
  void addChild(String childId) {
    if (!childIds.contains(childId)) {
      childIds.add(childId);
      itemCount = childIds.length;
    }
  }
  
  /// Remove a child item from the folder
  void removeChild(String childId) {
    childIds.remove(childId);
    itemCount = childIds.length;
  }
}