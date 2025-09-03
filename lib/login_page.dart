// lib/login_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'note_home_page.dart';
import 'database_manager.dart';
import 'utilisateur.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nomUtilisateurController =
      TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  late DatabaseManager _databaseManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabaseManager();
  }

  Future<void> _initializeDatabaseManager() async {
    try {
      _databaseManager = await DatabaseManager.getInstance();
      print("Database Manager initialisé avec succès !");
    } catch (e) {
      print("Erreur d'initialisation de la base de données : $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _login() async {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La base de données n\'est pas prête. Veuillez patienter.',
          ),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    final nomUtilisateur = _nomUtilisateurController.text;
    final motDePasse = _motDePasseController.text;

    if (nomUtilisateur.isEmpty || motDePasse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final utilisateur = await _databaseManager.getUtilisateur(
        nomUtilisateur,
        motDePasse,
      );

      if (utilisateur != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NoteHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nom d\'utilisateur ou mot de passe incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Erreur lors de la connexion : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la connexion. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _signup() async {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La base de données n\'est pas prête. Veuillez patienter.',
          ),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    final nomUtilisateur = _nomUtilisateurController.text;
    final motDePasse = _motDePasseController.text;

    if (nomUtilisateur.isEmpty || motDePasse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final nouvelUtilisateur = Utilisateur(
        nomUtilisateur: nomUtilisateur,
        motDePasse: motDePasse,
      );

      // Assurez-vous que le nom d'utilisateur n'existe pas déjà
      final existingUser = await _databaseManager.getUtilisateur(
        nomUtilisateur,
        '',
      );
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce nom d\'utilisateur est déjà pris.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await _databaseManager.insertUtilisateur(nouvelUtilisateur);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Erreur lors de l'inscription : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur s\'est produite. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /*void _continueWithoutRegistration() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const NoteHomePage()),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.notes, size: 100, color: Colors.white),
                      const SizedBox(height: 40),
                      Text(
                        'Bienvenue sur Note AI',
                        style: GoogleFonts.roboto(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _nomUtilisateurController,
                        decoration: InputDecoration(
                          labelText: 'Nom d\'utilisateur',
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: 'Entrez votre nom d\'utilisateur',
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _motDePasseController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: 'Entrez votre mot de passe',
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Se connecter',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _signup,
                        child: Text(
                          'S\'inscrire',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /*Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TextButton(
                      onPressed: _continueWithoutRegistration,
                      child: Text(
                        'Continuer sans inscription',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
    );
  }
}
