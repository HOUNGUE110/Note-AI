// lib/note_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_manager.dart';
import 'note.dart';

class NotePage extends StatefulWidget {
  final Note? note; // Note facultative pour l'édition
  const NotePage({super.key, this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _contenuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titreController.text = widget.note!.titre;
      _contenuController.text = widget.note!.contenu;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final databaseManager = await DatabaseManager.getInstance();
                await databaseManager.deleteNote(widget.note!.id!);
                Navigator.of(context).pop(); // Ferme le dialogue
                Navigator.of(context).pop(); // Revient à la page d'accueil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note supprimée avec succès !'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                print("Erreur lors de la suppression: $e");
                Navigator.of(context).pop(); // Ferme le dialogue
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 243, 255),
      appBar: AppBar(
        title: Text(
          'Mes notes',
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: widget.note != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteDialog();
                  },
                ),
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titreController,
              decoration: InputDecoration(
                labelText: 'Titre',
                labelStyle: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contenuController,
                decoration: InputDecoration(
                  labelText: 'Objets',
                  labelStyle: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: GoogleFonts.raleway(color: Colors.black),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final titre = _titreController.text;
                final contenu = _contenuController.text;

                if (titre.isEmpty || contenu.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final databaseManager = await DatabaseManager.getInstance();

                  if (widget.note != null) {
                    final noteMiseAJour = Note(
                      id: widget.note!.id,
                      titre: titre,
                      contenu: contenu,
                      dateCreation: widget.note!.dateCreation,
                    );
                    await databaseManager.updateNote(noteMiseAJour);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note mise à jour avec succès !'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  } else {
                    final nouvelleNote = Note(
                      titre: titre,
                      contenu: contenu,
                      dateCreation: DateTime.now(),
                    );
                    await databaseManager.insertNote(nouvelleNote);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note enregistrée avec succès !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de l\'enregistrement de la note'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: Text(
                'Valider...',
                style: GoogleFonts.raleway(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}