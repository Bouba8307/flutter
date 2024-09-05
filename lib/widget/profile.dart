import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _user = _auth.currentUser;
    });
    
    if (_user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
        setState(() {
          _userData = userDoc.data();
        });
      } catch (error) {
        // Handle the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de récupération des données : $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'), // Add your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black54),
                      onPressed: () {
                        Navigator.pop(context); // Go back to the previous screen
                      },
                    ),
                  ],
                ),
              ),

              // Profile Picture and Edit Icon
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: _userData?['image_url'] != null
                          ? NetworkImage(_userData!['image_url'])
                          : AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        onPressed: () {
                          // Implement your profile picture change functionality
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextField('Nom', _userData?['Nom'] ?? 'Non défini'),
                    const SizedBox(height: 15),
                    buildTextField('Prénom', _userData?['Prenom'] ?? 'Non défini'),
                    const SizedBox(height: 15),
                    buildTextField('Numéro', _userData?['Numéro'] ?? 'Non défini'),
                    const SizedBox(height: 15),
                    buildTextField('Email', _user?.email ?? 'Non défini' ),
                    const SizedBox(height: 15),
                    // buildTextField('Photo', _userData?['image_url']?.split('/').last ?? 'Non défini'),
                  ],
                ),
              ),

              // Buttons for Modify and Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Implement modify functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6A48FF),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Modifier', style: TextStyle(color: Colors.white),),
                    
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A48FF),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Déconnexion',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget buildTextField(String label, String placeholder, {bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            suffixIcon: isReadOnly ? const Icon(Icons.file_upload_outlined) : null,
          ),
        ),
      ],
    );
  }
}
