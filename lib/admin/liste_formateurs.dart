import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/widget/modifier_utilisateur.dart'; // Assure-toi d'importer la page de modification si nécessaire

class ListeFormateur extends StatefulWidget {
  @override
  _ListeFormateurState createState() => _ListeFormateurState();
}

class _ListeFormateurState extends State<ListeFormateur> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Formateurs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where('role', isEqualTo: 'formateur').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final users = snapshot.data?.docs;

          if (users == null || users.isEmpty) {
            return Center(child: Text('Aucun formateur trouvé.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final nom = user['Nom'];
              final prenom = user['Prenom'];
              final username = user['username'];
              final email = user['email'];
              final imageUrl = user['image_url'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                ),
                title: Text('$prenom $nom'),
                subtitle: Text(username),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ModifierUtilisateur(userId: user.id), // Passer l'id utilisateur
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
