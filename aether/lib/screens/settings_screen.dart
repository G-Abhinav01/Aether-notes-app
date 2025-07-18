import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/services/theme_service.dart';
import 'package:aether/services/settings_service.dart';
import 'package:aether/services/file_service.dart';
import 'package:aether/models/enums.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _totalStorageSize = 0;
  bool _isLoadingStorageSize = true;
  
  @override
  void initState() {
    super.initState();
    _loadStorageSize();
  }
  
  Future<void> _loadStorageSize() async {
    final fileService = FileService();
    final size = await fileService.getTotalStorageSize();
    
    setState(() {
      _totalStorageSize = size;
      _isLoadingStorageSize = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final settingsService = Provider.of<SettingsService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme settings
          ListTile(
            title: const Text('Theme'),
            subtitle: const Text('Choose app theme'),
            leading: const Icon(Icons.brightness_6),
            onTap: () => _showThemeDialog(context, themeService),
          ),
          
          // View mode settings
          ListTile(
            title: const Text('View Mode'),
            subtitle: Text(
              settingsService.getViewMode() == ViewMode.list
                  ? 'List View'
                  : 'Grid View',
            ),
            leading: const Icon(Icons.view_list),
            onTap: () => _showViewModeDialog(context, settingsService),
          ),
          
          // Sort options
          ListTile(
            title: const Text('Default Sort'),
            subtitle: Text(_getSortOptionText(settingsService.getSortOption())),
            leading: const Icon(Icons.sort),
            onTap: () => _showSortOptionDialog(context, settingsService),
          ),
          
          const Divider(),
          
          // Storage info
          ListTile(
            title: const Text('Storage Usage'),
            subtitle: _isLoadingStorageSize
                ? const Text('Calculating...')
                : Text(_formatFileSize(_totalStorageSize)),
            leading: const Icon(Icons.storage),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStorageSize,
            ),
          ),
          
          // Trash settings
          ListTile(
            title: const Text('Trash Retention'),
            subtitle: Text('${settingsService.getTrashRetentionDays()} days'),
            leading: const Icon(Icons.delete),
            onTap: () => _showTrashRetentionDialog(context, settingsService),
          ),
          
          const Divider(),
          
          // Backup settings
          ListTile(
            title: const Text('Auto Backup'),
            subtitle: Text(
              settingsService.getAutoBackup()
                  ? 'Enabled (Every ${settingsService.getBackupFrequency()} days)'
                  : 'Disabled',
            ),
            leading: const Icon(Icons.backup),
            onTap: () => _showBackupSettingsDialog(context, settingsService),
          ),
          
          // Manual backup
          ListTile(
            title: const Text('Create Backup Now'),
            leading: const Icon(Icons.save),
            onTap: () {
              // TODO: Implement manual backup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup created')),
              );
            },
          ),
          
          const Divider(),
          
          // About section
          ListTile(
            title: const Text('About Aether'),
            subtitle: const Text('Version 1.0.0'),
            leading: const Icon(Icons.info),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }
  
  void _showThemeDialog(BuildContext context, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              leading: const Icon(Icons.brightness_5),
              onTap: () {
                themeService.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              leading: const Icon(Icons.brightness_3),
              onTap: () {
                themeService.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('System'),
              leading: const Icon(Icons.brightness_auto),
              onTap: () {
                themeService.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showViewModeDialog(BuildContext context, SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose View Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('List View'),
              leading: const Icon(Icons.view_list),
              onTap: () async {
                await settingsService.setViewMode(ViewMode.list);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Grid View'),
              leading: const Icon(Icons.grid_view),
              onTap: () async {
                await settingsService.setViewMode(ViewMode.grid);
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSortOptionDialog(BuildContext context, SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Sort Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Name (A-Z)'),
              onTap: () async {
                await settingsService.setSortOption(SortOption.nameAsc);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Name (Z-A)'),
              onTap: () async {
                await settingsService.setSortOption(SortOption.nameDesc);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Date Created (Newest First)'),
              onTap: () async {
                await settingsService.setSortOption(SortOption.dateCreatedDesc);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Date Created (Oldest First)'),
              onTap: () async {
                await settingsService.setSortOption(SortOption.dateCreatedAsc);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Date Modified (Newest First)'),
              onTap: () async {
                await settingsService.setSortOption(SortOption.dateModifiedDesc);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Date Modified (Oldest First)'),
              onTap: () async {
                await settingsService.setSortOption(SortOption.dateModifiedAsc);
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTrashRetentionDialog(BuildContext context, SettingsService settingsService) {
    final options = [7, 14, 30, 60, 90];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trash Retention Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((days) {
            return ListTile(
              title: Text('$days days'),
              onTap: () async {
                await settingsService.setTrashRetentionDays(days);
                Navigator.pop(context);
                setState(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showBackupSettingsDialog(BuildContext context, SettingsService settingsService) {
    final currentAutoBackup = settingsService.getAutoBackup();
    final currentFrequency = settingsService.getBackupFrequency();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Backup Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Auto Backup'),
                  value: currentAutoBackup,
                  onChanged: (value) {
                    setState(() {
                      settingsService.setAutoBackup(value);
                    });
                  },
                ),
                if (currentAutoBackup)
                  ListTile(
                    title: const Text('Backup Frequency'),
                    subtitle: Text('Every $currentFrequency days'),
                    onTap: () {
                      Navigator.pop(context);
                      _showBackupFrequencyDialog(context, settingsService);
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.setState(() {});
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showBackupFrequencyDialog(BuildContext context, SettingsService settingsService) {
    final options = [1, 3, 7, 14, 30];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((days) {
            return ListTile(
              title: Text('Every $days days'),
              onTap: () async {
                await settingsService.setBackupFrequency(days);
                Navigator.pop(context);
                setState(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Aether',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      applicationLegalese: '© 2025 Aether App',
      children: const [
        SizedBox(height: 16),
        Text(
          'Aether is a mobile-first note and task management app with hierarchical organization.',
        ),
      ],
    );
  }
  
  String _getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.dateCreatedAsc:
        return 'Date Created (Oldest First)';
      case SortOption.dateCreatedDesc:
        return 'Date Created (Newest First)';
      case SortOption.dateModifiedAsc:
        return 'Date Modified (Oldest First)';
      case SortOption.dateModifiedDesc:
        return 'Date Modified (Newest First)';
      case SortOption.typeAsc:
        return 'Type (A-Z)';
      case SortOption.typeDesc:
        return 'Type (Z-A)';
    }
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}