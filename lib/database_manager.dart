// lib/database_manager.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note.dart';
import 'utilisateur.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  static Database? _database;
  static const String _databaseName = 'note_ai_database.db';

  DatabaseManager._internal();

  static Future<DatabaseManager> getInstance() async {
    if (_instance == null) {
      _instance = DatabaseManager._internal();
      await _instance!._initDatabase();
    }
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    throw Exception(
      'La base de données n\'a pas été initialisée. Appelez getInstance() d\'abord.',
    );
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, titre TEXT, contenu TEXT, dateCreation TEXT)',
        );
        return db.execute(
          'CREATE TABLE utilisateurs(id INTEGER PRIMARY KEY AUTOINCREMENT, nomUtilisateur TEXT UNIQUE, motDePasse TEXT)',
        );
      },
      version: 1,
    );
  }

  // Méthodes pour les notes
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'dateCreation DESC',
    );
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes pour les utilisateurs
  Future<int> insertUtilisateur(Utilisateur utilisateur) async {
    final db = await database;
    return await db.insert('utilisateurs', utilisateur.toMap());
  }

  Future<Utilisateur?> getUtilisateur(
    String nomUtilisateur,
    String motDePasse,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'utilisateurs',
      where: 'nomUtilisateur = ? AND motDePasse = ?',
      whereArgs: [nomUtilisateur, motDePasse],
    );
    if (maps.isNotEmpty) {
      return Utilisateur.fromMap(maps.first);
    }
    return null;
  }
}
