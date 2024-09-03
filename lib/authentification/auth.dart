import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_help/widget/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return AuthScreenState();
  }
}

class AuthScreenState extends State<AuthScreen> {
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  final _form = GlobalKey<FormState>();
  File? _selectedImage;

  var _isLogin = true;
  var _isAuthenticating = false;

Future<void> _submit() async {
  final isValid = _form.currentState!.validate();
  if (!isValid || (!_isLogin && _selectedImage == null)) {
    return;
  }

  _form.currentState!.save();
  try {
    setState(() {
      _isAuthenticating = true;
    });

    if (_isLogin) {
      // Sign in logic
      final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
      print('User signed in: ${userCredentials.user!.email}');
    } else {
      // Sign up logic
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

      final storageRef = FirebaseStorage.instance
          .ref('user_image')
          .child('${userCredentials.user!.uid}.png');

      // Upload image and get URL
      try {
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // Store user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'fullname': 'none', // Example field
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
          'role': '', // Example field
        });

        print('User data stored successfully in Firestore.');
      } on FirebaseException catch (e) {
        _showErrorSnackBar(
            'Image upload failed: ${e.message ?? 'Unknown error'}');
        return;
      } catch (e) {
        _showErrorSnackBar(
            'An error occurred while storing user data: ${e.toString()}');
        return;
      }
    }
  } on FirebaseAuthException catch (error) {
    _showErrorSnackBar(error.message ?? 'Authentication failed.');
  } catch (e) {
    _showErrorSnackBar('An unexpected error occurred: ${e.toString()}');
  } finally {
    setState(() {
      _isAuthenticating = false;
    });
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
            fit: BoxFit.cover, // Adapte l'image pour couvrir tout l'écran
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

                // Auth Form
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
                      if (!_isLogin)
                        _buildUsernameField(),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Mot de passe ?',
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
                        child: Text(_isLogin ? 'Connexion' : 'S\'inscrire'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Continue avec',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      _buildSocialIconsRow(),
                      const SizedBox(height: 20),
                      if (!_isAuthenticating)
                        //bouton de changement de vue
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
          if (value == null || value.trim().isEmpty || value.trim().length < 4) {
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
          hintText: 'Adresse mail',
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
          suffixIcon: Icon(Icons.visibility),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.trim().length < 6) {
            return 'Vous devez entrer un mot de passe de 6 caractères minimum';
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
          icon: Image.asset('assets/images/google.png'),
          iconSize: 50,
          onPressed: () {},
        ),
        IconButton(
          icon: Image.asset('assets/images/apple.png'),
          iconSize: 50,
          onPressed: () {},
        ),
        IconButton(
          icon: Image.asset('assets/images/facebook.png'),
          iconSize: 50,
          onPressed: () {},
        ),
      ],
    );
  }
}
