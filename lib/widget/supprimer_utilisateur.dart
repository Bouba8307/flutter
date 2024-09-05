import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SupprimerUtilisateur extends StatelessWidget {
  final String userId;

  const SupprimerUtilisateur({required this.userId});

  Future<void> _deleteUser(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Récupérer l'URL de l'image de l'utilisateur avant de supprimer
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final imageUrl = userDoc.data()?['image_url'];

        if (imageUrl != null) {
          final imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await imageRef.delete();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Utilisateur supprimé avec succès.')));
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supprimer Utilisateur')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _deleteUser(context),
          child: const Text('Supprimer Utilisateur'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ),
    );
  }
}
