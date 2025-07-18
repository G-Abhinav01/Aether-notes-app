import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/models/models.dart';
import 'package:aether/widgets/breadcrumb_navigation.dart';

class NoteScreen extends StatefulWidget {
  final String noteId;

  const NoteScreen({super.key, required this.noteId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  Note? _note;
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;
  bool _isEditing = false;

  // Auto-save timer
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final note = await contentRepository.getNote(widget.noteId);

      if (note != null) {
        setState(() {
          _note = note;
          _titleController.text = note.name;
          _contentController.text = note.content;
          _isLoading = false;
        });
      } else {
        // Note not found, navigate back
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading note: $e')));
      }
    }
  }

  void _setupAutoSave() {
    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    // Cancel existing timer
    _autoSaveTimer?.cancel();

    // Start new timer for auto-save (2 seconds after last change)
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (_hasUnsavedChanges && _note != null) {
        _saveNote();
      }
    });
  }

  Future<void> _saveNote() async {
    if (_note == null) return;

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );

      // Update note with current content
      final updatedNote = _note!.copyWith(
        name: _titleController.text.isNotEmpty
            ? _titleController.text
            : 'Untitled Note',
        content: _contentController.text,
        modifiedAt: DateTime.now(),
      );

      await contentRepository.updateContentItem(updatedNote);

      setState(() {
        _note = updatedNote;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (_isEditing) {
      // Focus on content when entering edit mode
      _contentFocusNode.requestFocus();
    }
  }

  void _showNoteOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildNoteOptionsSheet(),
    );
  }

  Widget _buildNoteOptionsSheet() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              _note?.isFavorite == true ? Icons.star : Icons.star_border,
            ),
            title: Text(
              _note?.isFavorite == true
                  ? 'Remove from Favorites'
                  : 'Add to Favorites',
            ),
            onTap: () {
              Navigator.pop(context);
              _toggleFavorite();
            },
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Manage Tags'),
            onTap: () {
              Navigator.pop(context);
              _showTagsDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Export Note'),
            onTap: () {
              Navigator.pop(context);
              _exportNote();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Move to Trash'),
            onTap: () {
              Navigator.pop(context);
              _moveToTrash();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_note == null) return;

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      await contentRepository.toggleFavorite(_note!.id);

      setState(() {
        _note = _note!.copyWith(isFavorite: !_note!.isFavorite);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _note!.isFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
      }
    }
  }

  void _showTagsDialog() {
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Tags'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current tags
            if (_note?.tags.isNotEmpty == true) ...[
              const Text(
                'Current Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _note!.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _note!.removeTag(tag);
                            _hasUnsavedChanges = true;
                          });
                          Navigator.pop(context);
                          _showTagsDialog(); // Refresh dialog
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Add new tag
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Add Tag',
                hintText: 'Enter tag name',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && _note != null) {
                  setState(() {
                    _note!.addTag(value);
                    _hasUnsavedChanges = true;
                  });
                  tagController.clear();
                  Navigator.pop(context);
                  _showTagsDialog(); // Refresh dialog
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
          if (tagController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                if (_note != null) {
                  setState(() {
                    _note!.addTag(tagController.text);
                    _hasUnsavedChanges = true;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
        ],
      ),
    ).then((_) => tagController.dispose());
  }

  Future<void> _exportNote() async {
    if (_note == null) return;

    try {
      final contentRepository = Provider.of<ContentRepository>(
        context,
        listen: false,
      );
      final exportPath = await contentRepository.exportItem(_note!.id);

      if (exportPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note exported to: $exportPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting note: $e')));
      }
    }
  }

  Future<void> _moveToTrash() async {
    if (_note == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Trash'),
        content: const Text(
          'Are you sure you want to move this note to trash?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move to Trash'),
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
        await contentRepository.trashItem(_note!.id);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note moved to trash')));
          context.pop(); // Navigate back
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error moving note to trash: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Note Not Found')),
        body: const Center(
          child: Text('The requested note could not be found.'),
        ),
      );
    }

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasUnsavedChanges) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                'You have unsaved changes. Do you want to save before leaving?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            ),
          );

          if (shouldSave == true) {
            await _saveNote();
          }

          if (context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_note!.name.isNotEmpty ? _note!.name : 'Untitled Note'),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveNote,
                tooltip: 'Save',
              ),
            IconButton(
              icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
              onPressed: _toggleEditing,
              tooltip: _isEditing ? 'Preview' : 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showNoteOptions,
              tooltip: 'More options',
            ),
          ],
        ),
        body: Column(
          children: [
            // Breadcrumb navigation
            const BreadcrumbNavigation(),

            // Note metadata
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created: ${_formatDate(_note!.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Modified: ${_formatDate(_note!.modifiedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_note!.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: _note!.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Note content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      enabled: _isEditing,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'Note title',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),

                    // Content field
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        enabled: _isEditing,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Start writing your note...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Formatting toolbar (when editing)
        bottomNavigationBar: _isEditing ? _buildFormattingToolbar() : null,
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold),
            onPressed: () => _insertFormatting('**', '**'),
            tooltip: 'Bold',
          ),
          IconButton(
            icon: const Icon(Icons.format_italic),
            onPressed: () => _insertFormatting('*', '*'),
            tooltip: 'Italic',
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () => _insertFormatting('- ', ''),
            tooltip: 'Bullet List',
          ),
          IconButton(
            icon: const Icon(Icons.format_list_numbered),
            onPressed: () => _insertFormatting('1. ', ''),
            tooltip: 'Numbered List',
          ),
          IconButton(
            icon: const Icon(Icons.format_quote),
            onPressed: () => _insertFormatting('> ', ''),
            tooltip: 'Quote',
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.keyboard_hide),
            onPressed: () => _contentFocusNode.unfocus(),
            tooltip: 'Hide Keyboard',
          ),
        ],
      ),
    );
  }

  void _insertFormatting(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );

      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset:
              selection.start +
              prefix.length +
              selectedText.length +
              suffix.length,
        ),
      );
    } else {
      // Insert at cursor position
      final cursorPos = selection.baseOffset;
      final newText = text.replaceRange(cursorPos, cursorPos, '$prefix$suffix');

      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPos + prefix.length),
      );
    }

    _onContentChanged();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
