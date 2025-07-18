import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final settingsService = Provider.of<SettingsService>(
        context,
        listen: false,
      );

      // Get recent items limit from settings
      final limit = settingsService.getRecentItemsLimit();

      final notes = await contentRepository.getRecentNotes(limit: limit);

      if (mounted) {
        setState(() {
          _recentNotes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recent notes: $e')),
        );
      }
    }
  }

  String _getPreviewText(String content) {
    // Remove basic markdown formatting for preview
    String preview = content
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Bold
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Italic
        .replaceAll(RegExp(r'^- ', multiLine: true), '') // Bullet points
        .replaceAll(RegExp(r'^\d+\. ', multiLine: true), '') // Numbered lists
        .replaceAll(RegExp(r'^> ', multiLine: true), '') // Quotes
        .replaceAll('\n', ' ') // Replace newlines with spaces
        .trim();

    return preview.length > 100 ? '${preview.substring(0, 100)}...' : preview;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentNotes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentNotes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No recent notes'),
                  SizedBox(height: 8),
                  Text(
                    'Create a note to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRecentNotes,
              child: ListView.builder(
                itemCount: _recentNotes.length,
                itemBuilder: (context, index) {
                  final note = _recentNotes[index];
                  final previewText = _getPreviewText(note.content);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        note.name.isNotEmpty ? note.name : 'Untitled Note',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (previewText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              previewText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Note format indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  note.format.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Word count
                              Text(
                                '${note.content.split(' ').length} words',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(width: 8),

                              // Modified date
                              Text(
                                'Modified: ${_formatDate(note.modifiedAt)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                            ],
                          ),

                          // Tags
                          if (note.tags.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: note.tags
                                  .take(3)
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (note.isFavorite)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        context.push('/note/${note.id}');
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
