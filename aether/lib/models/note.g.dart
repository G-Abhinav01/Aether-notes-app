// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
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
  content: json['content'] as String? ?? '',
  plainTextContent: json['plainTextContent'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  format:
      $enumDecodeNullable(_$NoteFormatEnumMap, json['format']) ??
      NoteFormat.richText,
);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'parentFolderId': instance.parentFolderId,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt.toIso8601String(),
  'isFavorite': instance.isFavorite,
  'isDeleted': instance.isDeleted,
  'content': instance.content,
  'plainTextContent': instance.plainTextContent,
  'tags': instance.tags,
  'format': _$NoteFormatEnumMap[instance.format]!,
};

const _$NoteFormatEnumMap = {
  NoteFormat.plainText: 'plainText',
  NoteFormat.richText: 'richText',
  NoteFormat.markdown: 'markdown',
};
