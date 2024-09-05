import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_help/admin/accueil_admin.dart';
import 'package:system_help/apprenant/accueil_apprenant.dart';
import 'package:system_help/apprenant/home.dart';
import 'package:system_help/formateur/accueil_formateur.dart';
import 'package:system_help/widget/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  var _enteredEmail = '';
  var _enteredNom = '';
  var _enteredPrenom = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  final _form = GlobalKey<FormState>();
  File? _selectedImage;

  var _isLogin = true;
  var _isAuthenticating = false;

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid || (!_isLogin && _selectedImage == null)) {
      _showErrorSnackBar('Veuillez remplir tous les champs.');
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        print('Utilisateur connecté : ${userCredentials.user!.email}');
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        String imageUrl = 'default_url';
        if (!kIsWeb && _selectedImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref('user_image')
              .child('${userCredentials.user!.uid}.png');

          try {
            await storageRef.putFile(_selectedImage!);
            imageUrl = await storageRef.getDownloadURL();
          } on FirebaseException catch (e) {
            _showErrorSnackBar(
                'Échec du téléchargement de l\'image : ${e.message ?? 'Erreur inconnue'}');
            return;
          }
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'nom': _enteredNom,
          'prenom': _enteredPrenom,
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
          'role': 'admin',
        });
      }

      if (_isLogin) {
        await _navigateBasedOnUserRole();
      }
    } on FirebaseAuthException catch (error) {
      _showErrorSnackBar(error.message ?? 'Échec de l\'authentification.');
    } catch (e) {
      _showErrorSnackBar(
          'Une erreur inattendue est survenue : ${e.toString()}');
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _navigateBasedOnUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        var role = userDoc.get('role');

        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminAccueil()));
        } else if (role == 'formateur') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const FormateurAccueil()));
        } else if (role == 'apprenant') {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    } catch (e) {
      _showErrorSnackBar(
          'Une erreur est survenue lors de la récupération du rôle.');
    }
  }

  void _showErrorSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      if (!_isLogin)
                        UserImagePicker(
                          onPickedImage: (pickedImage) {
                            _selectedImage = pickedImage;
                          },
                        ),
                      const SizedBox(height: 20),
                      if (!_isLogin) _buildNomField(),
                      const SizedBox(height: 20),
                      if (!_isLogin) _buildPrenomField(),
                      const SizedBox(height: 20),
                      if (!_isLogin) _buildUsernameField(),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isAuthenticating) const CircularProgressIndicator(),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          backgroundColor: const Color(0xFF6A48FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:(Text(_isLogin ? 'Connexion' : 'S\'inscrire', style: const TextStyle(color: Colors.white))),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Continuer avec',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      _buildSocialIconsRow(),
                      const SizedBox(height: 20),
                      if (!_isAuthenticating)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'Créer un compte'
                              : 'Je suis déjà inscrit(e)'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNomField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Nom',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.person),
        ),
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Veuillez entrer votre nom';
          }
          return null;
        },
        onSaved: (value) {
          _enteredNom = value!;
        },
      ),
    );
  }

  Widget _buildPrenomField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Prénom',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.person),
        ),
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Veuillez entrer votre prénom';
          }
          return null;
        },
        onSaved: (value) {
          _enteredPrenom = value!;
        },
      ),
    );
  }

  Widget _buildUsernameField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Nom d\'utilisateur',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.person),
        ),
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty ||
              value.trim().length < 4) {
            return 'Veuillez entrer un nom d\'utilisateur de 4 caractères minimum';
          }
          return null;
        },
        onSaved: (value) {
          _enteredUsername = value!;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Adresse email',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.trim().isEmpty || !value.contains('@')) {
            return 'Veuillez entrer une adresse email valide';
          }
          return null;
        },
        onSaved: (value) {
          _enteredEmail = value!;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Mot de passe',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.lock),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty ||
              value.trim().length < 6) {
            return 'Veuillez entrer un mot de passe d\'au moins 6 caractères';
          }
          return null;
        },
        onSaved: (value) {
          _enteredPassword = value!;
        },
      ),
    );
  }

  Widget _buildSocialIconsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.facebook),
          iconSize: 50,
          onPressed: () {},
        ),
        IconButton(
          icon: Image.asset('assets/images/google.png'),
          iconSize: 50,
          onPressed: () {},
        ),
      ],
    );
  }
}
