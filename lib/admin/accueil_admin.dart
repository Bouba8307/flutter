import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore Database
import 'package:system_help/admin/ajouter_apprenant.dart';
import 'package:system_help/admin/ajouter_formateur.dart';
import 'package:system_help/authentification/auth.dart';

import 'liste_apprenants.dart';
import 'liste_formateurs.dart';
import 'dashboard.dart'; // Make sure to import the correct file

void main() {
  runApp(const AdminAccueil());
}

class AdminAccueil extends StatefulWidget {
  const AdminAccueil({super.key});

  @override
  _AdminAccueilState createState() => _AdminAccueilState();
}

class _AdminAccueilState extends State<AdminAccueil> {
  int _selectedIndex = 0; // To track the selected menu item

  String adminName = 'Nom non disponible';
  String adminEmail = 'Email non disponible';

  final List<Widget> _pages = [
    DashboardPage(),
    ListeApprenant(),
    ListeFormateur(),
  ];

  @override
  void initState() {
    super.initState();
    _getAdminData();
  }

  Future<void> _getAdminData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userData.exists) {
          setState(() {
            adminName = userData['nom'] ?? 'Nom non disponible';
            adminEmail = userData['email'] ?? 'Email non disponible';
          });
        }
      } catch (e, stackTrace) {
        print('Erreur lors de la récupération des données : $e');
        print('Trace de la pile : $stackTrace');
        setState(() {
          adminName = 'Erreur de chargement';
          adminEmail = 'Erreur de chargement';
        });
      }
    } else {
      setState(() {
        adminName = 'Utilisateur non connecté';
        adminEmail = 'Utilisateur non connecté';
      });
    }
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Chercher',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              if (_selectedIndex == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AjouterApprenant(),
                  ),
                );
              } else if (_selectedIndex == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AjouterFormateur(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(adminName),
              accountEmail: Text(adminEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                    adminName.isNotEmpty ? adminName[0] + adminName[1] : 'A'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                _onMenuItemSelected(0);
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Apprenants'),
              onTap: () {
                _onMenuItemSelected(1);
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Formateurs'),
              onTap: () {
                _onMenuItemSelected(2);
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                 Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) =>  AuthScreen()));
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
