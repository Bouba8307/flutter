import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_help/widget/user_image_picker.dart';

class AjouterFormateur extends StatefulWidget {
  @override
  _AjouterFormateurState createState() => _AjouterFormateurState();
}

class _AjouterFormateurState extends State<AjouterFormateur> {
  final _formKey = GlobalKey<FormState>();
  String _enteredNom = '';
  String _enteredPrenom = '';
  String _enteredUsername = '';
  String _enteredEmail = '';
  File? _selectedImage;
  final _auth = FirebaseAuth.instance;
  final _defaultImageUrl = 'assets/icons/defautimage.svg'; // URL de l'image par défaut

  Future<void> _submit() async {
    
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    _formKey.currentState!.save();

    try {
      final userCredentials = await _auth.createUserWithEmailAndPassword(
        email: _enteredEmail,
        password: '12345678', // Mot de passe par défaut
      );

      String imageUrl = _defaultImageUrl;

      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref('user_images')
            .child('${userCredentials.user!.uid}.png');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'Nom': _enteredNom,
        'Prenom': _enteredPrenom,
        'username': _enteredUsername,
        'email': _enteredEmail,
        'image_url': imageUrl,
        'role': 'formateur',
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
      appBar: AppBar(title: Text('Ajouter Formateur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              UserImagePicker(onPickedImage: (pickedImage) {
                _selectedImage = pickedImage;
              }, defaultImageUrl: _defaultImageUrl),
              _buildNomField(),
              _buildPrenomField(),
              _buildUsernameField(),
              _buildEmailField(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Ajouter Formateur'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNomField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Nom'),
      validator: (value) => value == null || value.isEmpty ? 'Entrez un nom' : null,
      onSaved: (value) => _enteredNom = value!,
    );
  }

  Widget _buildPrenomField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Prénom'),
      validator: (value) => value == null || value.isEmpty ? 'Entrez un prénom' : null,
      onSaved: (value) => _enteredPrenom = value!,
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
      validator: (value) => value == null || value.length < 4
          ? '4 caractères minimum' : null,
      onSaved: (value) => _enteredUsername = value!,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      validator: (value) => value == null || !value.contains('@') ? 'Email valide' : null,
      onSaved: (value) => _enteredEmail = value!,
    );
  }
}
