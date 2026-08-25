import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditComing extends StatefulWidget {
  final String eventId;
  final bool? initialComing;

  const EditComing({
    super.key,
    required this.eventId,
    required this.initialComing,
  });

  @override
  State<EditComing> createState() => _EditComingState();
}

class _EditComingState extends State<EditComing> {
  late bool? coming;

  @override
  void initState() {
    super.initState();
    coming = widget.initialComing;
  }

  Future<void> setComing(bool value) async {
    try {
      final userId =
          Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) return;

      await Supabase.instance.client
          .from('members')
          .update({'coming': value})
          .eq('event_id', widget.eventId)
          .eq('user_id', userId);

      if (!mounted) return;

      setState(() {
        coming = value;
      });
    } catch (e) {
      print('Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => setComing(true),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                coming == true ? Colors.green : Colors.white70,
          ),
          child: const Icon(Icons.check_rounded),
        ),

        ElevatedButton(
          onPressed: () => setComing(false),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                coming == false ? Colors.red : Colors.white70,
          ),
          child: const Icon(Icons.close),
        ),
      ],
    );
  }
}