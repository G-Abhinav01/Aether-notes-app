// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageMetadata _$ImageMetadataFromJson(Map<String, dynamic> json) =>
    ImageMetadata(
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      location: json['location'] as String?,
      dateTaken: json['dateTaken'] == null
          ? null
          : DateTime.parse(json['dateTaken'] as String),
    );

Map<String, dynamic> _$ImageMetadataToJson(ImageMetadata instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'location': instance.location,
      'dateTaken': instance.dateTaken?.toIso8601String(),
    };

ImageItem _$ImageItemFromJson(Map<String, dynamic> json) => ImageItem(
  id: json['id'] as String?,
  name: json['name'] as String,
  parentFolderId: json['parentFolderId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  modifiedAt: json['modifiedAt'] == null
      ? null
      : DateTime.parse(json['modifiedAt'] as String),
  isFavorite: json['isFavorite'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
  filePath: json['filePath'] as String,
  thumbnailPath: json['thumbnailPath'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  mimeType: json['mimeType'] as String,
  metadata: ImageMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ImageItemToJson(ImageItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'parentFolderId': instance.parentFolderId,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt.toIso8601String(),
  'isFavorite': instance.isFavorite,
  'isDeleted': instance.isDeleted,
  'filePath': instance.filePath,
  'thumbnailPath': instance.thumbnailPath,
  'fileSize': instance.fileSize,
  'mimeType': instance.mimeType,
  'metadata': instance.metadata.toJson(),
};
