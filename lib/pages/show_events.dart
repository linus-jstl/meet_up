import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meet_up/buttons/edit_coming.dart';
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
    loadEvents();
    loadComing();
  }

  Future<void> loadEvents() async {
    try {
      final eventDetails = await supabase
          .from('event_details')
          .select()
          .or('time.gte.${DateTime.now().toIso8601String()},time.is.null',);

      setState(() {
        events = List<Map<String, dynamic>>.from(eventDetails);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void loadComing() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {return;}

      final data = await supabase
        .from('members')
        .select('event_id, coming')
        .eq('user_id', userId);
      
      setState(() {
        members = List<Map<String, dynamic>>.from(data);
      });

    } catch (e) {
      setState(() {
        error = e.toString();
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

      await loadEvents();
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

            return ListTile(
              leading: const Icon(Icons.event),
              title: Text(event['name']),
              subtitle: Text(
                event['time'].toString() + ", ".toString() +
                event['location'].toString() + "\n".toString() +
                event['event_id'].toString()),
              trailing: EditComing(eventId: event['event_id'], initialComing: coming),
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