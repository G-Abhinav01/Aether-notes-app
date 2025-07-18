import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/models/models.dart';
import 'package:aether/services/settings_service.dart';

class RecentNotesScreen extends StatefulWidget {
  const RecentNotesScreen({super.key});

  @override
  State<RecentNotesScreen> createState() => _RecentNotesScreenState();
}

class _RecentNotesScreenState extends State<RecentNotesScreen> {
  List<Note> _recentNotes = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecentNotes();
  }
  
  Future<void> _loadRecentNotes() async {
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    // Get recent items limit from settings
    final limit = settingsService.getRecentItemsLimit();
    
    final notes = await contentRepository.getRecentNotes(limit: limit);
    
    setState(() {
      _recentNotes = notes;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Notes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentNotes.isEmpty
              ? const Center(child: Text('No recent notes'))
              : ListView.builder(
                  itemCount: _recentNotes.length,
                  itemBuilder: (context, index) {
                    final note = _recentNotes[index];
                    return ListTile(
                      title: Text(note.name),
                      subtitle: Text(
                        _formatDate(note.modifiedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      leading: const Icon(Icons.description),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/note/${note.id}',
                        );
                      },
                    );
                  },
                ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}