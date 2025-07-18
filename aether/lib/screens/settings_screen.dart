import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/services/theme_service.dart';
import 'package:aether/services/settings_service.dart';
import 'package:aether/repositories/content_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  Map<String, int> _storageStats = {};

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
  }

  Future<void> _loadStorageStats() async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final stats = await contentRepository.getStorageStats();
      if (mounted) {
        setState(() {
          _storageStats = stats;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your notes, tasks, images, and folders. '
          'This action cannot be undone. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final contentRepository = Provider.of<ContentRepository>(
          context,
          listen: false,
        );
        await contentRepository.clearAllData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data has been cleared')),
          );
          _loadStorageStats(); // Refresh stats
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error clearing data: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _emptyTrash() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: const Text(
          'This will permanently delete all items in the trash. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final contentRepository = Provider.of<ContentRepository>(
          context,
          listen: false,
        );
        await contentRepository.emptyTrash();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trash has been emptied')),
          );
          _loadStorageStats(); // Refresh stats
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error emptying trash: $e')));
        }
      }
    }
  }

  String _formatCount(int count) {
    if (count == 0) return '0';
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Appearance Section
                _buildSectionHeader('Appearance'),
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      subtitle: Text(_getThemeModeText(themeService.themeMode)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeDialog(themeService),
                    );
                  },
                ),

                Consumer<SettingsService>(
                  builder: (context, settingsService, child) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.view_module),
                      title: const Text('Default Grid View'),
                      subtitle: const Text(
                        'Use grid view by default for folders',
                      ),
                      value: settingsService.defaultGridView,
                      onChanged: (value) {
                        settingsService.setDefaultGridView(value);
                      },
                    );
                  },
                ),

                // Storage Section
                _buildSectionHeader('Storage'),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Folders'),
                  trailing: Text(_formatCount(_storageStats['folders'] ?? 0)),
                ),
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Notes'),
                  trailing: Text(_formatCount(_storageStats['notes'] ?? 0)),
                ),
                ListTile(
                  leading: const Icon(Icons.task),
                  title: const Text('Tasks'),
                  trailing: Text(_formatCount(_storageStats['tasks'] ?? 0)),
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Images'),
                  trailing: Text(_formatCount(_storageStats['images'] ?? 0)),
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Trash Items'),
                  trailing: Text(_formatCount(_storageStats['trash'] ?? 0)),
                ),

                // Data Management Section
                _buildSectionHeader('Data Management'),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('Empty Trash'),
                  subtitle: const Text('Permanently delete all trashed items'),
                  onTap:
                      _storageStats['trash'] != null &&
                          _storageStats['trash']! > 0
                      ? _emptyTrash
                      : null,
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh Storage Stats'),
                  subtitle: const Text('Update storage information'),
                  onTap: _loadStorageStats,
                ),

                // Backup Section
                _buildSectionHeader('Backup & Export'),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Export All Data'),
                  subtitle: const Text('Export all content to files'),
                  onTap: _exportAllData,
                ),

                // Danger Zone
                _buildSectionHeader('Danger Zone'),
                ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: const Text(
                    'Clear All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Permanently delete all app data'),
                  onTap: _clearAllData,
                ),

                // About Section
                _buildSectionHeader('About'),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Open Source'),
                  subtitle: const Text('Built with Flutter'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Aether',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.note_alt, size: 48),
                      children: [
                        const Text(
                          'A modern note-taking and task management app built with Flutter.',
                        ),
                        const SizedBox(height: 16),
                        const Text('Features:'),
                        const Text('• Hierarchical folder organization'),
                        const Text('• Rich text notes with formatting'),
                        const Text('• Task management with priorities'),
                        const Text('• Image storage and viewing'),
                        const Text('• Full-text search capabilities'),
                        const Text('• Dark and light theme support'),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(ThemeService themeService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeService.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeService.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system setting'),
              value: ThemeMode.system,
              groupValue: themeService.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final exportPath = await contentRepository.exportAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to: $exportPath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
