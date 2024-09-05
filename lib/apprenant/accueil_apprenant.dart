import 'package:flutter/material.dart';

class ApprenantAccueil extends StatelessWidget {
  const ApprenantAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: const Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
