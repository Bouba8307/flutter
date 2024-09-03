import 'package:flutter/material.dart';
import 'package:system_help/widget/chat_messages.dart';
import 'package:system_help/widget/new_messages.dart';

void main() {
  runApp(Chat());
}

class Chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat UI',
      theme: ThemeData(
        primarySwatch: Colors.purple, // Optionally set a primary color or other theme data
      ),
      home: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Column for chat content
            Column(
              children: [
                Container(
                  color: Colors.transparent, // Ensures that the background image is visible behind the AppBar
                  child: AppBar(
                    title: const Text('Chat'),
                    backgroundColor: Colors.transparent, // Make AppBar background transparent
                    elevation: 0, // Remove shadow to show the background image clearly
                  ),
                ),
                const Expanded(child: ChatMessages()),
                const NewMessages(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
