import 'package:notes_app/models/note.dart';

class NoteServiceMock {
  List<Note> _notes = [];

  List<Note> getNotes() {
    return _notes;
  }

  void addNote(
      String title, String content) {
    final newNote = Note(
      key: _notes.length,
      title: title,
      content: content,
    );
    _notes.add(newNote);
  }

  void updateNote(
      int key, String title, String content) {
    final index = _notes.indexWhere((note) => note.key == key);
    if (index != -1) {
      _notes[index] = Note(
        key: key,
        title: title,
        content: content,
      );
    }
  }

  void deleteNote(
      int key) {
    _notes.removeWhere((note) => note.key == key);
  }
}