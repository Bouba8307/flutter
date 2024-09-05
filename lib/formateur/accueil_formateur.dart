import 'package:flutter/material.dart';
import 'package:system_help/formateur/ticket_formateur.dart';

class FormateurAccueil extends StatefulWidget {
  const FormateurAccueil({super.key});

  @override
  _FormateurAccueilState createState() => _FormateurAccueilState();
}

class _FormateurAccueilState extends State<FormateurAccueil> {
  @override
  void initState() {
    super.initState();
    // Use Future.delayed to navigate after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TicketManagementPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Formateur'),
      ),
      body: Center(
        child: const Text('Hello, World!'),
      ),
    );
  }
}
