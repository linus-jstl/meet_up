import 'package:flutter/material.dart';
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

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        return ListTile(
          leading: const Icon(Icons.event),
          title: Text(event['name']),
          subtitle: Text(event['event_id'].toString()),
        );
      },
    );
  }
}