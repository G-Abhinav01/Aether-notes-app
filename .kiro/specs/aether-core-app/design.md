# Design Document

## Overview

Aether is a Flutter-based mobile application that provides hierarchical note and task management through a file-system-like interface. The app follows Material Design 3 principles with custom theming support, implements a clean architecture pattern, and uses local SQLite storage with future cloud sync capabilities. The design emphasizes performance, offline-first functionality, and intuitive user experience across Android and iOS platforms.

## Architecture

### High-Level Architecture

The application follows a layered architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────┐
│           Presentation Layer        │
│  (Screens, Widgets, State Management)│
├─────────────────────────────────────┤
│            Business Layer           │
│     (Use Cases, Business Logic)     │
├─────────────────────────────────────┤
│             Data Layer              │
│   (Repositories, Data Sources)      │
├─────────────────────────────────────┤
│           Storage Layer             │
│      (SQLite, File System)         │
└─────────────────────────────────────┘
```

### State Management

- **Provider Pattern**: Using Flutter's Provider package for state management
- **ChangeNotifier**: For reactive UI updates and data binding
- **Repository Pattern**: For data access abstraction
- **Singleton Services**: For app-wide services like theme, storage, and navigation

### Navigation Architecture

- **Flutter Router (GoRouter)**: For declarative routing and deep linking support
- **Bottom Navigation**: Persistent navigation bar with 5 main sections
- **Hierarchical Navigation**: Stack-based navigation for folder traversal
- **Modal Navigation**: For creation dialogs and settings screens

## Components and Interfaces

### Core Data Models

#### ContentItem (Abstract Base Class)
```dart
abstract class ContentItem {
  String id;
  String name;
  String parentFolderId;
  DateTime createdAt;
  DateTime modifiedAt;
  bool isFavorite;
  bool isDeleted;
  ContentType type;
}
```

#### Folder Model
```dart
class Folder extends ContentItem {
  List<String> childIds;
  int itemCount;
  String colorTheme;
}
```

#### Note Model
```dart
class Note extends ContentItem {
  String content;
  String plainTextContent; // For search indexing
  List<String> tags;
  NoteFormat format; // Rich text, markdown, plain
}
```

#### Task Model
```dart
class Task extends ContentItem {
  String description;
  bool isCompleted;
  DateTime? dueDate;
  TaskPriority priority;
  List<String> tags;
}
```

#### ImageItem Model
```dart
class ImageItem extends ContentItem {
  String filePath;
  String thumbnailPath;
  int fileSize;
  String mimeType;
  ImageMetadata metadata;
}
```

### Key Services and Repositories

#### StorageService
- **Purpose**: Manages SQLite database operations and file system access
- **Key Methods**: 
  - `initializeDatabase()`
  - `executeQuery()`, `executeTransaction()`
  - `backupDatabase()`, `restoreDatabase()`

#### ContentRepository
- **Purpose**: Provides CRUD operations for all content types
- **Key Methods**:
  - `createItem()`, `updateItem()`, `deleteItem()`
  - `getItemsByFolder()`, `searchItems()`
  - `moveItem()`, `copyItem()`

#### NavigationService
- **Purpose**: Manages app navigation and folder hierarchy
- **Key Methods**:
  - `navigateToFolder()`, `navigateBack()`
  - `getBreadcrumbs()`, `getCurrentPath()`

#### ThemeService
- **Purpose**: Manages app theming and user preferences
- **Key Methods**:
  - `setTheme()`, `getTheme()`
  - `applySystemTheme()`, `savePreferences()`

#### SearchService
- **Purpose**: Handles content search and indexing
- **Key Methods**:
  - `searchContent()`, `indexContent()`
  - `parseSearchQuery()`, `filterResults()`

### UI Components Architecture

#### Screen Components
- **HomeScreen**: Root folder view with bottom navigation
- **FolderScreen**: Generic folder content display
- **NoteEditorScreen**: Rich text editing interface
- **TaskEditorScreen**: Task creation and editing
- **SearchScreen**: Search interface and results
- **SettingsScreen**: App configuration and preferences

#### Reusable Widgets
- **ContentListItem**: Displays folder/note/task in list format
- **ContentGridItem**: Displays content in grid format
- **FloatingCreateButton**: Multi-option creation button
- **BreadcrumbNavigation**: Folder path navigation
- **SearchBar**: Contextual search input
- **SelectionToolbar**: Multi-select action toolbar

## Data Models

### Database Schema

#### content_items table
```sql
CREATE TABLE content_items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type INTEGER NOT NULL,
  parent_folder_id TEXT,
  created_at INTEGER NOT NULL,
  modified_at INTEGER NOT NULL,
  is_favorite INTEGER DEFAULT 0,
  is_deleted INTEGER DEFAULT 0,
  content_data TEXT, -- JSON blob for type-specific data
  search_content TEXT, -- Indexed content for search
  FOREIGN KEY (parent_folder_id) REFERENCES content_items(id)
);
```

#### app_settings table
```sql
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);
```

#### search_index table
```sql
CREATE TABLE search_index (
  content_id TEXT,
  term TEXT,
  frequency INTEGER,
  PRIMARY KEY (content_id, term),
  FOREIGN KEY (content_id) REFERENCES content_items(id)
);
```

### File System Structure
```
/app_documents/
├── images/
│   ├── originals/
│   └── thumbnails/
├── exports/
├── backups/
└── temp/
```

## Error Handling

### Error Categories
1. **Storage Errors**: Database corruption, disk space, file access
2. **Network Errors**: Future sync operations, export failures
3. **Validation Errors**: Invalid input, constraint violations
4. **System Errors**: Permission issues, memory constraints

### Error Handling Strategy
- **Graceful Degradation**: App continues functioning with limited features
- **User Feedback**: Clear error messages with actionable solutions
- **Automatic Recovery**: Retry mechanisms for transient failures
- **Error Logging**: Comprehensive logging for debugging and analytics

### Error Recovery Mechanisms
```dart
class ErrorHandler {
  static Future<T> withRetry<T>(
    Future<T> Function() operation,
    {int maxRetries = 3}
  );
  
  static void handleStorageError(StorageException error);
  static void showUserFriendlyError(String message);
  static void logError(Exception error, StackTrace stackTrace);
}
```

## Testing Strategy

### Unit Testing
- **Model Classes**: Data validation, serialization/deserialization
- **Services**: Business logic, data transformations
- **Repositories**: CRUD operations, error handling
- **Utilities**: Search algorithms, file operations

### Widget Testing
- **Screen Widgets**: UI rendering, user interactions
- **Custom Widgets**: Component behavior, state changes
- **Navigation**: Route transitions, parameter passing

### Integration Testing
- **Database Operations**: Full CRUD workflows
- **File System**: Image storage and retrieval
- **Search Functionality**: End-to-end search scenarios
- **Theme Switching**: UI updates across theme changes

### Test Structure
```dart
// Example test organization
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── repositories/
├── widget/
│   ├── screens/
│   └── components/
└── integration/
    ├── database/
    ├── navigation/
    └── search/
```

### Performance Testing
- **Database Query Performance**: Large dataset operations
- **UI Responsiveness**: Smooth scrolling, animation performance
- **Memory Usage**: Image loading, large content handling
- **Startup Time**: App initialization and data loading

## UI/UX Design Specifications

### Material Design 3 Implementation
- **Dynamic Color**: System-based color theming
- **Typography**: Material 3 type scale
- **Elevation**: Proper shadow and surface hierarchy
- **Motion**: Smooth transitions and micro-interactions

### Dark Mode Support
- **Automatic Detection**: System theme following
- **Manual Override**: User preference setting
- **Consistent Theming**: All components support both themes
- **Accessibility**: Proper contrast ratios maintained

### Responsive Design
- **Adaptive Layouts**: Different layouts for tablets
- **Flexible Grid**: Content adapts to screen size
- **Touch Targets**: Minimum 48dp touch areas
- **Safe Areas**: Proper handling of notches and system UI

### Accessibility Features
- **Screen Reader Support**: Semantic labels and hints
- **High Contrast**: Enhanced visibility options
- **Font Scaling**: Support for system font size preferences
- **Keyboard Navigation**: Full app navigation without touch

## Performance Considerations

### Database Optimization
- **Indexing Strategy**: Optimized queries for search and navigation
- **Lazy Loading**: Content loaded on-demand
- **Connection Pooling**: Efficient database connection management
- **Query Optimization**: Minimized database round trips

### Memory Management
- **Image Caching**: Efficient image loading and caching
- **Widget Disposal**: Proper cleanup of resources
- **Stream Management**: Subscription cleanup and memory leaks prevention
- **Large Content Handling**: Pagination and virtualization

### Storage Efficiency
- **Image Compression**: Automatic image optimization
- **Database Compaction**: Regular database maintenance
- **Thumbnail Generation**: Efficient preview creation
- **Cleanup Routines**: Automatic removal of orphaned data

## Security Considerations

### Data Protection
- **Local Encryption**: Sensitive data encryption at rest
- **Secure File Storage**: Protected app directory usage
- **Input Validation**: Comprehensive input sanitization
- **SQL Injection Prevention**: Parameterized queries

### Privacy
- **No Telemetry**: No user data collection in base version
- **Local-First**: All data stored locally by default
- **Export Control**: User controls data export and sharing
- **Permission Management**: Minimal required permissions