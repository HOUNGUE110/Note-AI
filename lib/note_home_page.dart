// lib/note_home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_manager.dart';
import 'note.dart';
import 'note_page.dart';
import 'ai_note_page';

class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  late DatabaseManager _databaseManager;
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabaseManager();
  }

  Future<void> _initializeDatabaseManager() async {
    _databaseManager = await DatabaseManager.getInstance();
    await _loadNotes();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final notes = await _databaseManager.getNotes();

    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  void _goToAddNotePage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NotePage()));
    _loadNotes();
  }

  void _goToEditNotePage(Note note) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => NotePage(note: note)));
    _loadNotes();
  }

  void _goToAiNotePage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AiNotePage()));
    _loadNotes();
  }

  Future<void> _deleteNote(int id) async {
    // Affiche un dialogue de confirmation avant la suppression
    final bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      try {
        await _databaseManager.deleteNote(id);
        _loadNotes(); // Recharge la liste pour mettre à jour l'affichage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note supprimée !'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression de la note.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes AI',
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: Image.asset('assets/icons/gemini.png', width: 32, height: 32),
          onPressed: _goToAiNotePage,
        ),
        actions: [
          IconButton(
            onPressed: _goToAddNotePage,
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Ajouter une note',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _notes.isEmpty
                      ? const Center(
                          child: Text(
                            'Liste vide, ajoutez une note!',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: ListTile(
                                title: Text(note.titre),
                                subtitle: Text(
                                  note.contenu,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  _goToEditNotePage(note);
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        _deleteNote(note.id!);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        _goToEditNotePage(note);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ElevatedButton.icon(
                    onPressed: _goToAddNotePage,
                    icon: const Icon(Icons.add, color: Colors.indigo),
                    label: Text(
                      'Ajouter une note',
                      style: GoogleFonts.raleway(
                        color: Colors.indigo,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.indigo, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
