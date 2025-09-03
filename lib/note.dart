// lib/note.dart

class Note {
  int? id;
  String titre;
  String contenu;
  DateTime dateCreation;

  Note({
    this.id,
    required this.titre,
    required this.contenu,
    required this.dateCreation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      titre: map['titre'],
      contenu: map['contenu'],
      dateCreation: DateTime.parse(map['dateCreation']),
    );
  }
}
