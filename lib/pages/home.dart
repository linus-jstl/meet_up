import 'package:flutter/material.dart';
import 'package:meet_up/buttons/logout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    const Center(child: Text('Termine')),
    Center(child: Text('Du bist eingeloggt als:\n${Supabase.instance.client.auth.currentUser?.email}')),
    const LogoutButton(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _pages[_currentIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex; // Aktualisiert die Ansicht
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Treffen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}