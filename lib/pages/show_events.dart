import 'package:flutter/material.dart';
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
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final data = await supabase
          .from('event_details')
          .select()
          .or('time.gte.${DateTime.now().toIso8601String()},time.is.null',);

      setState(() {
        events = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
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

      await loadEvents();
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return ListTile(
            leading: const Icon(Icons.event),
            title: Text(event['name']),
            subtitle: Text(
              event['time'].toString() + ", ".toString() +
              event['location'].toString() + "\n".toString() +
              event['event_id'].toString()),
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