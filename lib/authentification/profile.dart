import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/background.jpg'), // Add your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black54),
                      onPressed: () {
                        Navigator.pop(
                            context); // Go back to the previous screen
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
                    const CircleAvatar(
                      radius: 55,
                      backgroundImage: AssetImage(
                          'assets/images/profile_placeholder.png'), // Profile picture placeholder
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
              const SizedBox(height: 30),

              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextField('Nom', 'Barry'),
                    const SizedBox(height: 15),
                    buildTextField('Prénom', 'melpeters@gmail.com'),
                    const SizedBox(height: 15),
                    buildTextField('Numéro', '+223 93546806'),
                    const SizedBox(height: 15),
                    buildTextField('Email', 'Barry@gmail.com'),
                    const SizedBox(height: 15),
                    buildTextField('Photo', 'Fichier.png', isReadOnly: true),
                  ],
                ),
              ),

              // Buttons for Modify and Logout
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Implement modify functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6A48FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Modifier'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Implement logout functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6A48FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Déconnexion'),
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
  Widget buildTextField(String label, String placeholder,
      {bool isReadOnly = false}) {
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            suffixIcon:
                isReadOnly ? const Icon(Icons.file_upload_outlined) : null,
          ),
        ),
      ],
    );
  }
}
