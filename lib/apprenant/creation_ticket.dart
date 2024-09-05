import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateTicketPage extends StatefulWidget {
  @override
  _CreateTicketPageState createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _category = 'Technique'; // Default category

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final ticketRef = FirebaseFirestore.instance.collection('tickets').doc();
    
    await ticketRef.set({
      'description': _descriptionController.text,
      'category': _category,
      'status': 'Attente',
      'createdBy': userId,
    });

    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: <String>['Technique', 'Pédagogique', 'Autre']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Catégorie'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTicket,
                child: Text('Soumettre le Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
