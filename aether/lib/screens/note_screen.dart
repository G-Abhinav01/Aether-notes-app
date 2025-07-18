import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/models/models.dart';

class NoteScreen extends StatefulWidget {
  final String noteId;
  
  const NoteScreen({super.key, required this.noteId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _contentController;
  Note? _note;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _loadNote();
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadNote() async {
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    final note = await contentRepository.getNote(widget.noteId);
    
    if (note != null) {
      setState(() {
        _note = note;
        _contentController.text = note.content;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveNote() async {
    if (_note == null) return;
    
    final contentRepository = Provider.of<ContentRepository>(context, listen: false);
    
    // Update note content
    _note!.updateContent(_contentController.text);
    
    // Save to repository
    await contentRepository.updateContentItem(_note!);
    
    // Show save confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_note?.name ?? 'Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _note == null
              ? const Center(child: Text('Note not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Start typing...',
                    ),
                  ),
                ),
    );
  }
}