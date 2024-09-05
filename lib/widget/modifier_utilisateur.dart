import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_help/widget/user_image_picker.dart';

class ModifierUtilisateur extends StatefulWidget {
  final String userId;

  ModifierUtilisateur({required this.userId});

  @override
  _ModifierUtilisateurState createState() => _ModifierUtilisateurState();
}

class _ModifierUtilisateurState extends State<ModifierUtilisateur> {
  final _formKey = GlobalKey<FormState>();
  String _enteredNom = '';
  String _enteredPrenom = '';
  String _enteredUsername = '';
  String _enteredEmail = '';
  File? _selectedImage;
  String? _existingImageUrl;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        setState(() {
          _enteredNom = userData['Nom'];
          _enteredPrenom = userData['Prenom'];
          _enteredUsername = userData['username'];
          _enteredEmail = userData['email'];
          _existingImageUrl = userData['image_url'];
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $error')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    _formKey.currentState!.save();

    try {
      String imageUrl = _existingImageUrl ?? 'assets/icon/defautimage.png';

      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref('user_images')
            .child('${widget.userId}.png');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'Nom': _enteredNom,
        'Prenom': _enteredPrenom,
        'username': _enteredUsername,
        'email': _enteredEmail,
        'image_url': imageUrl,
      });
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier Utilisateur')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                UserImagePicker(
                    onPickedImage: (pickedImage) {
                      _selectedImage = pickedImage;
                    },
                    defaultImageUrl:
                        _existingImageUrl ?? 'assets/icon/defautimage.png'),
                _buildNomField(),
                _buildPrenomField(),
                _buildUsernameField(),
                _buildEmailField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Modifier Utilisateur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNomField() {
    return TextFormField(
      initialValue: _enteredNom,
      decoration: InputDecoration(labelText: 'Nom'),
      validator: (value) =>
          value == null || value.isEmpty ? 'Entrez un nom' : null,
      onSaved: (value) => _enteredNom = value!,
    );
  }

  Widget _buildPrenomField() {
    return TextFormField(
      initialValue: _enteredPrenom,
      decoration: InputDecoration(labelText: 'Prénom'),
      validator: (value) =>
          value == null || value.isEmpty ? 'Entrez un prénom' : null,
      onSaved: (value) => _enteredPrenom = value!,
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      initialValue: _enteredUsername,
      decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
      validator: (value) =>
          value == null || value.length < 4 ? '4 caractères minimum' : null,
      onSaved: (value) => _enteredUsername = value!,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      initialValue: _enteredEmail,
      decoration: InputDecoration(labelText: 'Email'),
      validator: (value) =>
          value == null || !value.contains('@') ? 'Email valide' : null,
      onSaved: (value) => _enteredEmail = value!,
    );
  }
}
