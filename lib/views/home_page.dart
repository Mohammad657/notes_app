import 'package:flutter/material.dart';
import 'package:notes_app/services/note/note_service.dart';
import 'package:notes_app/models/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NoteService _noteService = NoteService();
  List<Note> notes = [];
  Map<int, bool> isEditing = {};
  Map<int, TextEditingController> titleControllers = {};
  Map<int, TextEditingController> contentControllers = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await _noteService.getNotes();
    setState(() {
      notes = data.reversed.toList();
      isEditing = {for (var note in notes) note.key: false};
      for (var note in notes) {
        titleControllers[note.key] =
            TextEditingController(text: note.title);
        contentControllers[note.key] =
            TextEditingController(text: note.content);
      }
    });
  }

  void _saveNote(
      String title, String content) async {
    if (title.isNotEmpty && content.isNotEmpty) {
      await _noteService.addNote(
          title, content);
      _loadNotes();
    }
  }

  void _updateNote(
      int key, String title, String content) async {
    await _noteService.updateNote(
        key, title, content);
    setState(() {
      isEditing[key] = false;
    });
    _loadNotes();
  }

  void _deleteNote(
      int key) async {
    await _noteService.deleteNote(
        key);
    _loadNotes();
  }

  void _saveAllEdits() {
    for (var note in notes) {
      final key = note.key;
      if (isEditing[key] == true) {
        final title = titleControllers[key]!.text;
        final content = contentControllers[key]!.text;
        _updateNote(
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _saveAllEdits();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notes App', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '${notes.length}',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: notes.isEmpty
            ? Center(child: Text('No notes yet! Add a new note.'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final key = note.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onLongPress: () {
                          _saveAllEdits();
                          setState(() {
                            isEditing[key] = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isEditing[key]!
                                  ? TextField(
                                      controller: titleControllers[key],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        hintText: 'Edit title',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue, width: 2),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      note.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                              SizedBox(height: 8),
                              isEditing[key]!
                                  ? Column(
                                      children: [
                                        TextField(
                                          controller:
                                              contentControllers[key],
                                          style: TextStyle(fontSize: 16),
                                          decoration: InputDecoration(
                                            hintText: 'Edit content',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            _updateNote(
                                              key,
                                              titleControllers[key]!.text,
                                              contentControllers[key]!.text,
                                            );
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      note.content,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54),
                                    ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteNote(key),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final titleController = TextEditingController();
            final contentController = TextEditingController();

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add Note'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(hintText: 'Title'),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: contentController,
                        decoration: InputDecoration(hintText: 'Content'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _saveNote(
                          titleController.text,
                          contentController.text,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}