import 'package:json_annotation/json_annotation.dart';
import 'content_item.dart';
import 'enums.dart';

part 'task.g.dart';

/// Task model for to-do items
@JsonSerializable(explicitToJson: true)
class Task extends ContentItem {
  /// Description of the task
  String description;
  
  /// Whether the task is completed
  bool isCompleted;
  
  /// Due date for the task (optional)
  DateTime? dueDate;
  
  /// Priority level of the task
  TaskPriority priority;
  
  /// Tags associated with the task
  List<String> tags;
  
  Task({
    String? id,
    required String name,
    String? parentFolderId,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool isFavorite = false,
    bool isDeleted = false,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.tags = const [],
  }) : super(
    id: id,
    name: name,
    parentFolderId: parentFolderId,
    createdAt: createdAt,
    modifiedAt: modifiedAt,
    isFavorite: isFavorite,
    isDeleted: isDeleted,
    type: ContentType.task,
  );
  
  /// Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$TaskToJson(this);
  
  @override
  Task copyWith({
    String? name,
    String? parentFolderId,
    DateTime? modifiedAt,
    bool? isFavorite,
    bool? isDeleted,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    List<String>? tags,
  }) {
    return Task(
      id: this.id,
      name: name ?? this.name,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdAt: this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tags: tags ?? List.from(this.tags),
    );
  }
  
  @override
  bool validate() {
    return super.validate();
  }
  
  /// Toggle completion status
  void toggleCompletion() {
    isCompleted = !isCompleted;
    modifiedAt = DateTime.now();
  }
  
  /// Check if task is overdue
  bool isOverdue() {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }
  
  /// Add a tag to the task
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      modifiedAt = DateTime.now();
    }
  }
  
  /// Remove a tag from the task
  void removeTag(String tag) {
    if (tags.remove(tag)) {
      modifiedAt = DateTime.now();
    }
  }
}