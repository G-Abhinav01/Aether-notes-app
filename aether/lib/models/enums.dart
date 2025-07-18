// Content type enum
enum ContentType {
  folder,
  note,
  task,
  image
}

// Task priority enum
enum TaskPriority {
  low,
  medium,
  high,
  urgent
}

// Note format enum
enum NoteFormat {
  plainText,
  richText,
  markdown
}

// View mode enum
enum ViewMode {
  list,
  grid
}

// Sort option enum
enum SortOption {
  nameAsc,
  nameDesc,
  dateCreatedAsc,
  dateCreatedDesc,
  dateModifiedAsc,
  dateModifiedDesc,
  typeAsc,
  typeDesc
}

// Extension methods for enums
extension ContentTypeExtension on ContentType {
  String get name {
    switch (this) {
      case ContentType.folder:
        return 'Folder';
      case ContentType.note:
        return 'Note';
      case ContentType.task:
        return 'Task';
      case ContentType.image:
        return 'Image';
    }
  }
  
  String get icon {
    switch (this) {
      case ContentType.folder:
        return 'folder';
      case ContentType.note:
        return 'description';
      case ContentType.task:
        return 'check_circle';
      case ContentType.image:
        return 'image';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
  
  int get value {
    switch (this) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
      case TaskPriority.urgent:
        return 3;
    }
  }
}