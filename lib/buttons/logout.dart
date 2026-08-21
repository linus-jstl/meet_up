import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutButton extends StatelessWidget {
  const new({super.key});

  void logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(onPressed: logout, child:Icon(Icons.logout)),
    );
  }
}