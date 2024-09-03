import 'package:flutter/material.dart';

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
        primarySwatch: Colors.purple,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final List<Map<String, String>> chats = [
    {'name': 'Mamadou Traore', 'message': 'C\'est ok', 'time': '10h09'},
    {'name': 'Mamadou Traore', 'message': 'C\'est ok', 'time': '10h09'},
    {
      'name': 'Tienou Konteré',
      'message': 'Merci beaucoup',
      'time': 'yesterday'
    },
    {'name': 'Chaka Diabaté', 'message': 'Bien !', 'time': '5 Mars'},
    {'name': 'Daouda Fomba', 'message': 'Bien vu merci !', 'time': '4 Mars'},
    {'name': 'Peter Landt', 'message': 'Cool 😊', 'time': '4 Fevrier'},
    {'name': 'Janice Nelson', 'message': 'Hello!', 'time': '3 Fevrier'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Chercher',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              chats[index]['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(chats[index]['message']!),
            trailing: Text(chats[index]['time']!),
          );
        },
      ),
    );
  }
}
