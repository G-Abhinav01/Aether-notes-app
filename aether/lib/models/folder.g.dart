// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Folder _$FolderFromJson(Map<String, dynamic> json) => Folder(
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
  childIds:
      (json['childIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  colorTheme: json['colorTheme'] as String?,
);

Map<String, dynamic> _$FolderToJson(Folder instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'parentFolderId': instance.parentFolderId,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt.toIso8601String(),
  'isFavorite': instance.isFavorite,
  'isDeleted': instance.isDeleted,
  'childIds': instance.childIds,
  'colorTheme': instance.colorTheme,
};
