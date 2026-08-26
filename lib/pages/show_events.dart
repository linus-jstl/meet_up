import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meet_up/buttons/delete_event.dart';
import 'package:meet_up/buttons/edit_coming.dart';
import 'package:meet_up/buttons/invite_members.dart';
import 'package:meet_up/pages/add_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShowEvents extends StatefulWidget {
  const ShowEvents({super.key});

  @override
  State<ShowEvents> createState() => _ShowEventsState();
}

class _ShowEventsState extends State<ShowEvents> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
}

Future<void> loadData() async {
  try {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    final results = await Future.wait([
      supabase
          .from('event_details')
          .select()
          .or(
            'time.gte.${DateTime.now().toIso8601String()},time.is.null',
          ),

      supabase
          .from('members')
          .select()
          .eq('user_id', userId),
    ]);

    if (!mounted) return;

    setState(() {
      events = List<Map<String, dynamic>>.from(results[0]);
      members = List<Map<String, dynamic>>.from(results[1]);
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = e.toString();
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Text('Fehler: $error'),
      );
    }

    if (events.isEmpty) {
      return const Center(
        child: Text('Keine Events gefunden'),
      );
    }

    void addEvent() async {
      await Navigator.push(
        context, 
        MaterialPageRoute(
          builder: ((context) => AddEventPage()))
      );

      await loadData();
    }

    return Scaffold(
      body: 
        ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final member = members.firstWhere(
              (member) => member['event_id'] == event['event_id'],
            );

            final bool coming = member['coming'];
            final bool admin = member['is_admin'];

            return ListTile(
              leading: const Icon(Icons.event),
              title: Text(event['name']),
              subtitle: Text(
                event['time'].toString() + ", ".toString() +
                event['location'].toString() + "\n".toString() +
                event['event_id'].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (admin) InviteButton(eventId: event['event_id']),
                  const SizedBox(width: 8,),
                  if (admin) DeleteButton(eventId: event['event_id'], onDeleted: loadData),
                  const SizedBox(width: 32,),
                  EditComing(eventId: event['event_id'], initialComing: coming),
                ],
              )
            );
          },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addEvent,
        icon: const Icon(Icons.add),
        label: const Text('Treffen hinzufügen'),
      )
    );
  }
}