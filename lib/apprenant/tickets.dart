import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:system_help/apprenant/creation_ticket.dart'; // Import the CreateTicketPage

class Tickets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tickets'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('createdBy', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return ListTile(
                title: Text(ticket['description']),
                subtitle: Text(
                    'Catégorie: ${ticket['category']}\nStatut: ${ticket['status']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateTicketPage(),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Créer un Ticket',
      ),
    );
  }
}
