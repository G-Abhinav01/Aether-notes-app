# Storage and Sync Architecture

## Overview

Aether implements a cost-effective, scalable storage strategy that starts with zero server costs and grows with the user base. The architecture prioritizes local-first storage with user-controlled cloud backup, eliminating infrastructure costs while providing reliable data access and sync capabilities.

## Core Storage Philosophy

### Local-First Architecture
- **Primary Storage**: All data stored locally on user's device using SQLite
- **Offline Capability**: 100% functionality without internet connection
- **User Data Ownership**: Users maintain complete control over their data
- **Zero Server Costs**: No infrastructure costs for basic functionality

### Progressive Sync Strategy
- **Phase 1**: Local-only storage with manual backup/restore
- **Phase 2**: Integration with user's personal cloud storage
- **Phase 3**: Optional premium real-time sync for paying users

## Phase 1: Local Storage Foundation

### SQLite Database Implementation
```dart
class LocalStorageService {
  static Database? _database;
  static const String _databaseName = 'aether_local.db';
  static const int _databaseVersion = 1;

  // Initialize local database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    // Create all necessary tables
    await db.execute('''
      CREATE TABLE content_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        parent_folder_id TEXT,
        created_at INTEGER NOT NULL,
        modified_at INTEGER NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        content_data TEXT,
        search_content TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
}
```

### File System Storage for Images
```dart
class LocalFileService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _imagesDirectory async {
    final path = await _localPath;
    final imagesDir = Directory('$path/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return File(imagesDir.path);
  }

  // Store images locally with compression
  static Future<String> saveImage(File imageFile) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'img_$timestamp.jpg';
    final String localPath = await _localPath;
    final String fullPath = '$localPath/images/$fileName';
    
    // Compress and save image
    final compressedImage = await _compressImage(imageFile);
    await compressedImage.copy(fullPath);
    
    return fullPath;
  }
}
```

### Benefits of Local-First Approach
- **Zero Infrastructure Costs**: No server or database hosting fees
- **Instant Performance**: No network latency for data operations
- **Complete Offline Access**: Full functionality without internet
- **Privacy by Design**: Data never leaves user's device unless they choose
- **Unlimited Storage**: Limited only by device storage capacity

## Phase 2: User's Personal Cloud Integration

### Google Drive Integration (WhatsApp Model)
```dart
class UserCloudBackup {
  static const String _backupFileName = 'aether_backup.json';
  
  // Connect to user's Google Drive
  static Future<void> authenticateGoogleDrive() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/drive.file'],
    );
    
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;
      // Store auth tokens for backup operations
      await _storeAuthTokens(auth.accessToken!, auth.refreshToken!);
    }
  }

  // Create backup file from local database
  static Future<Map<String, dynamic>> createBackupData() async {
    final db = await LocalStorageService.database;
    
    // Export all content items
    final List<Map<String, dynamic>> contentItems = await db.query('content_items');
    final List<Map<String, dynamic>> settings = await db.query('app_settings');
    
    return {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'content_items': contentItems,
      'app_settings': settings,
    };
  }

  // Upload backup to user's Google Drive
  static Future<void> uploadBackup() async {
    try {
      final backupData = await createBackupData();
      final String jsonString = jsonEncode(backupData);
      
      // Upload to user's Google Drive
      await _uploadToGoogleDrive(jsonString, _backupFileName);
      
      // Update last backup timestamp
      await _updateLastBackupTime();
    } catch (e) {
      throw BackupException('Failed to upload backup: $e');
    }
  }

  // Restore from user's Google Drive
  static Future<void> restoreFromBackup() async {
    try {
      final String? backupContent = await _downloadFromGoogleDrive(_backupFileName);
      if (backupContent == null) {
        throw BackupException('No backup found in Google Drive');
      }
      
      final Map<String, dynamic> backupData = jsonDecode(backupContent);
      await _restoreLocalDatabase(backupData);
      
    } catch (e) {
      throw BackupException('Failed to restore backup: $e');
    }
  }
}
```

### iCloud Integration (iOS)
```dart
class iCloudBackup {
  static const String _backupFileName = 'aether_backup.json';
  
  // Check if iCloud is available
  static Future<bool> isICloudAvailable() async {
    // Use cloud_firestore or similar package to check iCloud availability
    return await CloudStorage.isAvailable();
  }

  // Save backup to iCloud Documents
  static Future<void> saveToICloud(Map<String, dynamic> backupData) async {
    final String jsonString = jsonEncode(backupData);
    await CloudStorage.writeFile(_backupFileName, jsonString);
  }

  // Restore from iCloud Documents
  static Future<Map<String, dynamic>?> restoreFromICloud() async {
    final String? content = await CloudStorage.readFile(_backupFileName);
    if (content != null) {
      return jsonDecode(content);
    }
    return null;
  }
}
```

### Multi-Platform Cloud Support
```dart
class UniversalCloudBackup {
  // Detect available cloud services
  static Future<List<CloudProvider>> getAvailableProviders() async {
    List<CloudProvider> providers = [];
    
    if (Platform.isAndroid) {
      providers.add(CloudProvider.googleDrive);
      providers.add(CloudProvider.dropbox);
      providers.add(CloudProvider.oneDrive);
    } else if (Platform.isIOS) {
      providers.add(CloudProvider.iCloud);
      providers.add(CloudProvider.googleDrive);
      providers.add(CloudProvider.dropbox);
    }
    
    return providers;
  }

  // Let user choose their preferred cloud service
  static Future<void> setupCloudBackup(CloudProvider provider) async {
    switch (provider) {
      case CloudProvider.googleDrive:
        await UserCloudBackup.authenticateGoogleDrive();
        break;
      case CloudProvider.iCloud:
        await iCloudBackup.isICloudAvailable();
        break;
      case CloudProvider.dropbox:
        await DropboxBackup.authenticate();
        break;
      case CloudProvider.oneDrive:
        await OneDriveBackup.authenticate();
        break;
    }
  }
}

enum CloudProvider {
  googleDrive,
  iCloud,
  dropbox,
  oneDrive
}
```

### Benefits of User's Cloud Integration
- **Zero Storage Costs**: Users utilize their existing cloud storage
- **Cross-Device Access**: Backup/restore across multiple devices
- **User Control**: Users manage their own data and privacy
- **Familiar Experience**: Similar to WhatsApp backup model
- **Multiple Options**: Support for various cloud providers

## Phase 3: Premium Real-Time Sync

### Firebase Integration for Premium Users
```dart
class PremiumSyncService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  
  // Initialize Firebase for premium users only
  static Future<void> initializePremiumSync() async {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
  }

  // Sync content item to Firebase
  static Future<void> syncContentItem(ContentItem item) async {
    if (!await _isPremiumUser()) return;
    
    try {
      await _firestore!
          .collection('users')
          .doc(_auth!.currentUser!.uid)
          .collection('content_items')
          .doc(item.id)
          .set(item.toJson());
          
      // Also update local database
      await LocalStorageService.updateContentItem(item);
    } catch (e) {
      // Fallback to local-only if sync fails
      await LocalStorageService.updateContentItem(item);
    }
  }

  // Listen for real-time updates
  static Stream<List<ContentItem>> watchContentItems(String folderId) {
    if (!_isPremiumUser()) {
      // Return local data stream for free users
      return LocalStorageService.watchContentItems(folderId);
    }
    
    return _firestore!
        .collection('users')
        .doc(_auth!.currentUser!.uid)
        .collection('content_items')
        .where('parent_folder_id', isEqualTo: folderId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContentItem.fromJson(doc.data()))
            .toList());
  }

  // Conflict resolution for simultaneous edits
  static Future<ContentItem> resolveConflict(
    ContentItem localItem, 
    ContentItem remoteItem
  ) async {
    // Use timestamp-based resolution
    if (localItem.modifiedAt.isAfter(remoteItem.modifiedAt)) {
      return localItem;
    } else {
      return remoteItem;
    }
  }
}
```

### Supabase Alternative (Open Source)
```dart
class SupabaseSyncService {
  static SupabaseClient? _client;
  
  static Future<void> initializeSupabase() async {
    _client = SupabaseClient(
      'YOUR_SUPABASE_URL',
      'YOUR_SUPABASE_ANON_KEY',
    );
  }

  // Real-time sync with Supabase
  static Future<void> syncWithSupabase(ContentItem item) async {
    if (!await _isPremiumUser()) return;
    
    await _client!
        .from('content_items')
        .upsert(item.toJson());
  }

  // Listen for real-time changes
  static Stream<List<ContentItem>> subscribeToChanges(String userId) {
    return _client!
        .from('content_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data
            .map((item) => ContentItem.fromJson(item))
            .toList());
  }
}
```

## Cost Analysis and Scaling

### Free Tier Costs (Your Costs)
- **Local Storage**: $0 (uses device storage)
- **User Cloud Backup**: $0 (users pay for their own cloud storage)
- **Development**: Your time only
- **App Store Fees**: $124/year total (Apple $99 + Google $25)

### Premium Tier Costs (Per 1000 Premium Users)
- **Firebase Costs**: ~$25-50/month
- **AI API Costs**: ~$100-200/month (depending on usage)
- **Total Monthly Costs**: ~$125-250
- **Premium Revenue**: 1000 users × $4.99 = $4,990/month
- **Profit Margin**: ~95% after infrastructure costs

### Scaling Projections

#### Year 1 (10,000 total users, 500 premium)
- **Infrastructure Costs**: ~$60/month
- **Premium Revenue**: ~$2,500/month
- **Net Profit**: ~$2,440/month

#### Year 2 (100,000 total users, 7,000 premium)
- **Infrastructure Costs**: ~$350/month
- **Premium Revenue**: ~$35,000/month
- **Net Profit**: ~$34,650/month

#### Year 3 (500,000 total users, 35,000 premium)
- **Infrastructure Costs**: ~$1,500/month
- **Premium Revenue**: ~$175,000/month
- **Net Profit**: ~$173,500/month

## Implementation Roadmap

### Phase 1: MVP (Months 1-2)
- [ ] Implement SQLite local storage
- [ ] Create local file management for images
- [ ] Build export/import functionality
- [ ] Add manual backup creation

### Phase 2: Cloud Integration (Months 3-4)
- [ ] Google Drive API integration
- [ ] iCloud backup support (iOS)
- [ ] Automatic backup scheduling
- [ ] Cross-device restore functionality

### Phase 3: Premium Sync (Months 5-6)
- [ ] Firebase/Supabase integration
- [ ] Real-time sync for premium users
- [ ] Conflict resolution system
- [ ] Offline-first sync queue

### Phase 4: Advanced Features (Months 7-8)
- [ ] Multi-device collaboration
- [ ] Shared folder functionality
- [ ] Version history and rollback
- [ ] Advanced sync settings

## Technical Implementation Details

### Database Schema for Sync
```sql
-- Add sync-related columns to existing tables
ALTER TABLE content_items ADD COLUMN sync_status INTEGER DEFAULT 0;
ALTER TABLE content_items ADD COLUMN last_synced INTEGER DEFAULT 0;
ALTER TABLE content_items ADD COLUMN sync_version INTEGER DEFAULT 1;

-- Sync status values:
-- 0: Not synced (local only)
-- 1: Synced successfully
-- 2: Pending sync
-- 3: Sync conflict
```

### Sync Queue Management
```dart
class SyncQueue {
  static final List<SyncOperation> _pendingOperations = [];
  
  static Future<void> addToQueue(SyncOperation operation) async {
    _pendingOperations.add(operation);
    await _processSyncQueue();
  }
  
  static Future<void> _processSyncQueue() async {
    while (_pendingOperations.isNotEmpty && await _hasInternetConnection()) {
      final operation = _pendingOperations.removeAt(0);
      try {
        await operation.execute();
      } catch (e) {
        // Re-add to queue for retry
        _pendingOperations.insert(0, operation);
        break;
      }
    }
  }
}
```

### Error Handling and Fallbacks
```dart
class SyncErrorHandler {
  static Future<void> handleSyncError(SyncError error) async {
    switch (error.type) {
      case SyncErrorType.networkUnavailable:
        // Queue for later sync
        await SyncQueue.addToQueue(error.operation);
        break;
        
      case SyncErrorType.conflictDetected:
        // Show conflict resolution UI
        await _showConflictResolution(error.conflictData);
        break;
        
      case SyncErrorType.quotaExceeded:
        // Notify user about storage limits
        await _showQuotaExceededDialog();
        break;
        
      case SyncErrorType.authenticationFailed:
        // Re-authenticate user
        await _reauthenticateUser();
        break;
    }
  }
}
```

## Security and Privacy Considerations

### Data Encryption
```dart
class DataEncryption {
  // Encrypt sensitive data before cloud backup
  static String encryptData(String data, String userKey) {
    final key = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    return encrypter.encrypt(data, iv: iv).base64;
  }
  
  // Decrypt data after cloud restore
  static String decryptData(String encryptedData, String userKey) {
    // Implement decryption logic
    return decryptedData;
  }
}
```

### Privacy Protection
- **Local-First**: Data stays on device by default
- **User Consent**: Explicit permission for cloud backup
- **Encryption**: All cloud backups encrypted with user's key
- **No Analytics**: No user data collection without consent
- **GDPR Compliance**: Full data portability and deletion rights

## Monitoring and Analytics

### Sync Performance Metrics
```dart
class SyncMetrics {
  static Future<void> trackSyncOperation(SyncOperation operation) async {
    final metrics = {
      'operation_type': operation.type.toString(),
      'duration_ms': operation.duration.inMilliseconds,
      'success': operation.success,
      'error_type': operation.error?.type.toString(),
      'data_size_bytes': operation.dataSize,
    };
    
    // Only track performance metrics, not user data
    await AnalyticsService.trackEvent('sync_operation', metrics);
  }
}
```

### Cost Monitoring
```dart
class CostMonitoring {
  static Future<void> trackResourceUsage() async {
    final usage = {
      'firebase_reads': await _getFirebaseReads(),
      'firebase_writes': await _getFirebaseWrites(),
      'storage_used_mb': await _getStorageUsage(),
      'ai_api_calls': await _getAIApiCalls(),
    };
    
    await AnalyticsService.trackEvent('resource_usage', usage);
  }
}
```

This architecture provides a solid foundation that starts with zero costs and scales efficiently as your user base grows, while maintaining excellent user experience and data reliability.