import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:system_help/widget/supprimer_utilisateur.dart';


class ListeApprenant extends StatefulWidget {
  @override
  _ListeApprenantState createState() => _ListeApprenantState();
}

class _ListeApprenantState extends State<ListeApprenant> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Apprenants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where('role', isEqualTo: 'apprenant').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final users = snapshot.data?.docs;

          if (users == null || users.isEmpty) {
            return Center(child: Text('Aucun apprenant trouvé.'));
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
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SupprimerUtilisateur(userId: user.id), // Passer l'id utilisateur
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
