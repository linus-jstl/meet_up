import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteButton extends StatelessWidget {
  final String eventId;
  final Future<void> Function() onDeleted;

  const new({
    super.key,
    required this.eventId,
    required this.onDeleted,
  });

  Future<void> _deleteEvent() async { 

  try {
    await Supabase.instance.client
      .from('events')
      .delete()
      .eq('id', eventId);

    await onDeleted();

  } catch (e) {
    debugPrint('Löschen fehlgeschlagen: $e');
  }
    
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _deleteEvent, 
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(
          color: Colors.red
        )
      ),
      child: Icon(Icons.delete_outline),
    );
  }
}