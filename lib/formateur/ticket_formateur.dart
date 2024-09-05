import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TicketManagementPage extends StatefulWidget {
  @override
  _TicketManagementPageState createState() => _TicketManagementPageState();
}

class _TicketManagementPageState extends State<TicketManagementPage> {
  final _firestore = FirebaseFirestore.instance;
  final _replyController = TextEditingController();

  Future<void> _changeTicketStatus(String ticketId, String newStatus) async {
    await _firestore.collection('tickets').doc(ticketId).update({
      'status': newStatus,
    });

    if (newStatus == 'En cours') {
      // Notify the user that the ticket has been taken
    } else if (newStatus == 'Résolu') {
      final ticketDoc = await _firestore.collection('tickets').doc(ticketId).get();
      final creatorId = ticketDoc['createdBy'];
      // Notify the creator about the resolution
    }
  }

  Future<void> _addReply(String ticketId) async {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty) return;

    await _firestore.collection('tickets').doc(ticketId).collection('replies').add({
      'text': replyText,
      'createdBy': FirebaseAuth.instance.currentUser!.uid,
      'createdAt': Timestamp.now(),
    });

    _replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Tickets'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('tickets').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description: ${ticket['description']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Catégorie: ${ticket['category']}'),
                      Text('Statut: ${ticket['status']}'),
                      SizedBox(height: 8),
                      TextField(
                        controller: _replyController,
                        decoration: InputDecoration(
                          labelText: 'Répondre au ticket',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _addReply(ticket.id) as Future<void>,
                            
                            child: Text('Répondre'),
                          ),
                          SizedBox(width: 8),
                          PopupMenuButton<String>(
                            
                            onSelected: (status) {
                              _changeTicketStatus(ticket.id, status);
                            },
                            itemBuilder: (context) {
                              return ['En cours', 'Résolu'].map((status) {
                                return PopupMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList();
                            },
                            child: ElevatedButton(
                              onPressed: () {
                                _changeTicketStatus(ticket.id, 'En cours');
                              },
                              child: Text('Changer Statut'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Display replies
                      StreamBuilder(
                        stream: _firestore.collection('tickets').doc(ticket.id).collection('replies').orderBy('createdAt').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final replies = snapshot.data!.docs;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: replies.map((reply) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.reply, size: 16, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(child: Text(reply['text'])),
                                  ],
                                  
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
