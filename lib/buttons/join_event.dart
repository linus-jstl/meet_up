import 'package:flutter/material.dart';
import 'package:meet_up/main.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JoinButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => showDialog(
        context: context, 
        builder: (context) => JoinEvent() 
      ), 
      label: Text('Event Beitreten'),
      icon: Icon(PhosphorIcons.plus()),
    );
  }
}

class JoinEvent extends StatefulWidget {

  const new({
    super.key,
  });

  @override
  State<JoinEvent> createState() => _JoinEventState();
}

class _JoinEventState extends State<JoinEvent> {

  final codeController = TextEditingController();
  bool loading = false;
  bool joined = false;

  @override void dispose() { 
    codeController.dispose(); 
    super.dispose(); 
  }

  Future<void> joinEvent(String joinCode) async {

    setState(() {
      loading = true;
    });

    final eventId = await getEventId(joinCode);

    if (!mounted) {return;}

    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    if (eventId == '') {return;}

    try {

      final existingMember = await supabase
        .from('members')
        .select()
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMember != null) {
      debugPrint('User ist bereits Mitglied');
      
      setState(() {
        loading = false;
      });

      return;
    }


      await Supabase.instance.client
        .from('members')
        .insert({
          'event_id': eventId,
          'user_id': supabase.auth.currentUser?.id,
      });

      if (!mounted) {return;}

      setState(() {
        loading = false;
        joined = true;
      });

    } catch (e) {
      debugPrint('Event konnte nicht beigetreten werden: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<String> getEventId(String joinCode) async{
    try {
      final data = await supabase
        .from('events')
        .select('id')
        .eq('invite_code', joinCode)
        .maybeSingle();

      if (data == null) {debugPrint('Event nicht gefunden'); return '';}
      return data['id'];
    } catch (e) {
      debugPrint('Fehler beim Abrufen de Events: $e');
      return '';
    }
    

  }

  @override Widget build(BuildContext context) { 
    return AlertDialog( 
      title: const Text('Treffen beitreten'), 
      content: TextField( 
        controller: codeController, 
        maxLength: 6, 
        textCapitalization: TextCapitalization.characters, 
        textAlign: TextAlign.center, 
        style: const TextStyle( 
          fontSize: 24, 
          letterSpacing: 4, 
          fontWeight: FontWeight.bold, ), 
        decoration: const InputDecoration( 
          labelText: 'Einladungscode', 
          hintText: 'ABC123', 
          counterText: '', ), ), 
      actions: [ 
        FloatingActionButton.extended(
          onPressed: () => joinEvent(codeController.text.trim()), 
          icon: loading ? CircularProgressIndicator() : joined ? Icon(PhosphorIcons.check()) : Icon(PhosphorIcons.plus()),
          label: Text('Beitreten'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schließen'),
        ),
      ], 
    ); 
  }
}

