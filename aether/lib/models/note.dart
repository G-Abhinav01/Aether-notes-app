import 'package:json_annotation/json_annotation.dart';
import 'content_item.dart';
import 'enums.dart';

part 'note.g.dart';

/// Note model for text content
@JsonSerializable(explicitToJson: true)
class Note extends ContentItem {
  /// Rich text content of the note
  String content;
  
  /// Plain text version of content for search indexing
  String plainTextContent;
  
  /// Tags associated with the note
  List<String> tags;
  
  /// Format of the note (plain text, rich text, markdown)
  NoteFormat format;
  
  Note({
    String? id,
    required String name,
    String? parentFolderId,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool isFavorite = false,
    bool isDeleted = false,
    this.content = '',
    String? plainTextContent,
    this.tags = const [],
    this.format = NoteFormat.richText,
  }) : 
    plainTextContent = plainTextContent ?? content,
    super(
      id: id,
      name: name,
      parentFolderId: parentFolderId,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      isFavorite: isFavorite,
      isDeleted: isDeleted,
      type: ContentType.note,
    );
  
  /// Create from JSON
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$NoteToJson(this);
  
  @override
  Note copyWith({
    String? name,
    String? parentFolderId,
    DateTime? modifiedAt,
    bool? isFavorite,
    bool? isDeleted,
    String? content,
    String? plainTextContent,
    List<String>? tags,
    NoteFormat? format,
  }) {
    return Note(
      id: this.id,
      name: name ?? this.name,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdAt: this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      content: content ?? this.content,
      plainTextContent: plainTextContent ?? this.plainTextContent,
      tags: tags ?? List.from(this.tags),
      format: format ?? this.format,
    );
  }
  
  @override
  bool validate() {
    return super.validate() && content.isNotEmpty;
  }
  
  /// Update content and automatically update plainTextContent
  void updateContent(String newContent) {
    content = newContent;
    plainTextContent = _stripFormatting(newContent);
    modifiedAt = DateTime.now();
  }
  
  /// Strip formatting from rich text to create plain text
  String _stripFormatting(String richText) {
    // Simple implementation - in a real app, this would handle HTML/markdown tags
    return richText;
  }
  
  /// Add a tag to the note
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      modifiedAt = DateTime.now();
    }
  }
  
  /// Remove a tag from the note
  void removeTag(String tag) {
    if (tags.remove(tag)) {
      modifiedAt = DateTime.now();
    }
  }
}