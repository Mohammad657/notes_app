import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/note/note_service.dart';

class NotesViewModel extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  List<Note> notes = [];
  Map<int, bool> isEditing = {};
  Map<int, TextEditingController> titleControllers = {};
  Map<int, TextEditingController> contentControllers = {};

  NotesViewModel() {
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await _noteService.getNotes();
    notes = data.reversed.toList();
    isEditing = {for (var note in notes) note.key: false};
    for (var note in notes) {
      titleControllers[note.key] =
          TextEditingController(text: note.title);
      contentControllers[note.key] =
          TextEditingController(text: note.content);
    }
    notifyListeners();
  }

  void saveNote(
      String title, String content) {
    if (title.isNotEmpty && content.isNotEmpty) {
      _noteService.addNote(
          title, content);
      _loadNotes();
    }
  }

  void updateNote(
      int key, String title, String content) {
    _noteService.updateNote(
        key, title, content);
    isEditing[key] = false;
    _loadNotes();
  }

  void deleteNote(
      int key) {
    _noteService.deleteNote(
        key);
    _loadNotes();
  }

  void saveAllEdits() {
    for (var note in notes) {
      final key = note.key;
      if (isEditing[key] == true) {
        final title = titleControllers[key]!.text;
        final content = contentControllers[key]!.text;
        updateNote(
            key, title, content);
      }
    }
  }

  @override
  void dispose() {
    titleControllers.forEach((key, controller) {
      controller.dispose();
    });
    contentControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }
}