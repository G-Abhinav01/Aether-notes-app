import 'package:json_annotation/json_annotation.dart';
import 'content_item.dart';
import 'enums.dart';

part 'image_item.g.dart';

/// Image metadata class
@JsonSerializable(explicitToJson: true)
class ImageMetadata {
  /// Width of the image in pixels
  final int width;
  
  /// Height of the image in pixels
  final int height;
  
  /// Location where the image was taken (if available)
  final String? location;
  
  /// Date when the image was taken (if available)
  final DateTime? dateTaken;
  
  ImageMetadata({
    required this.width,
    required this.height,
    this.location,
    this.dateTaken,
  });
  
  /// Create from JSON
  factory ImageMetadata.fromJson(Map<String, dynamic> json) => _$ImageMetadataFromJson(json);
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ImageMetadataToJson(this);
}

/// Image content item model
@JsonSerializable(explicitToJson: true)
class ImageItem extends ContentItem {
  /// Path to the image file in local storage
  String filePath;
  
  /// Path to the thumbnail image
  String thumbnailPath;
  
  /// Size of the file in bytes
  int fileSize;
  
  /// MIME type of the image
  String mimeType;
  
  /// Metadata for the image
  ImageMetadata metadata;
  
  ImageItem({
    String? id,
    required String name,
    String? parentFolderId,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool isFavorite = false,
    bool isDeleted = false,
    required this.filePath,
    required this.thumbnailPath,
    required this.fileSize,
    required this.mimeType,
    required this.metadata,
  }) : super(
    id: id,
    name: name,
    parentFolderId: parentFolderId,
    createdAt: createdAt,
    modifiedAt: modifiedAt,
    isFavorite: isFavorite,
    isDeleted: isDeleted,
    type: ContentType.image,
  );
  
  /// Create from JSON
  factory ImageItem.fromJson(Map<String, dynamic> json) => _$ImageItemFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$ImageItemToJson(this);
  
  @override
  ImageItem copyWith({
    String? name,
    String? parentFolderId,
    DateTime? modifiedAt,
    bool? isFavorite,
    bool? isDeleted,
    String? filePath,
    String? thumbnailPath,
    int? fileSize,
    String? mimeType,
    ImageMetadata? metadata,
  }) {
    return ImageItem(
      id: this.id,
      name: name ?? this.name,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdAt: this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
    );
  }
  
  @override
  bool validate() {
    return super.validate() && filePath.isNotEmpty && thumbnailPath.isNotEmpty;
  }
}