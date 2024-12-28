import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/hive_service.dart';

class NoteService {
  final HiveService _hiveService = HiveService();

  Future<List<Note>> getNotes() async {
    final box = await _hiveService.openBox('Notes');
    return box.keys.map((key) {
      final value = box.get(key);
      return Note(
        key: key,
        title: value['title'],
        content: value['content'],
      );
    }).toList();
  }

  Future<void> addNote(String title, String content) async {
    final box = await _hiveService.openBox('Notes');
    final newNote = {"title": title, "content": content};
    box.add(newNote);
  }

  Future<void> updateNote(
      int key, String title, String content) async {
    final box = await _hiveService.openBox('Notes');
    box.put(key, {"title": title, "content": content});
  }

  Future<void> deleteNote(
      int key) async {
    final box = await _hiveService.openBox('Notes');
    box.delete(key);
  }
}