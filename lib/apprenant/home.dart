import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../authentification/chat.dart'; // Import the Chat screen
import '../widget/profile.dart'; // Import the Profile screen
import 'tickets.dart'; // Import the Tickets screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    Home(),
    Chat(),
    Tickets(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _pages[_selectedIndex], // Display the selected page
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF6A48FF),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dummy page widget for the home tab
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and Profile Icon Row
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Icon
              const Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.black54,
              ),
              // Actions Row
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Icon(
                    Icons.notifications_active,
                    size: 40,
                    color: Colors.black54,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Greeting Text
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Bonjour, Bienvenue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Recherche des Tickets...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.black54),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Tickets Text
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tickets',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black54,
            ),
          ),
        ),
        // Rest of the content goes here
      ],
    );
  }
}
