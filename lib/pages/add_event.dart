import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEventPage extends StatefulWidget {
  const new({super.key});


  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

void changeEventDetails(dynamic context, String event_id, String name, String? dateTimeString, String location) async{
  try {
    await Supabase.instance.client
        .from('event_details')
        .update({
          'name': name,
          'time': dateTimeString,
          'location': location,
        })
        .eq('event_id', event_id);

  } catch (e) {
    print('Fehler beim Aktualisieren: $e');
  }
}

class _AddEventPageState extends State<AddEventPage> {

  final nameController = TextEditingController();
  final dateTimeController = TextEditingController();
  final locationController = TextEditingController();

  DateTime? selectedDateTime;

  TextFormField dateTimePicker()  {
    return TextFormField(
      controller: dateTimeController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Datum und Uhrzeit',
        suffixIcon: Icon(Icons.calendar_month),
      ),
      onTap: () async {
        final now = DateTime.now();

        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year, now.month, now.day),
          lastDate: DateTime(now.year + 100),
        );

        if (!mounted) {return;}

        if (date == null) return;

        final time = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 18, minute: 0),
        );

        if (time == null) return;

        selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          dateTimeController.text =
              '${selectedDateTime!.day.toString().padLeft(2, '0')}.'
              '${selectedDateTime!.month.toString().padLeft(2, '0')}.'
              '${selectedDateTime!.year} '
              '${selectedDateTime!.hour.toString().padLeft(2, '0')}:'
              '${selectedDateTime!.minute.toString().padLeft(2, '0')}';
        });
      },
    );
  }

  TextField nameField() {
    return TextField(
      controller: nameController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
      ),
    );
  }

  TextField locationField() {
    return TextField(
      controller: locationController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: 'Ort',
        border: OutlineInputBorder(),
      ),
    );
  }

  void _addEvent() async {
  try {
    final name = nameController.text.trim();
    final dateTime = selectedDateTime?.toIso8601String();
    final location = locationController.text.trim();

    final eventId = await Supabase.instance.client.rpc(
      'create_event'
    );

    if (!mounted) {return;}

    changeEventDetails(context, eventId, name, dateTime, location);

    print('Event erstellt: $eventId');

    if (mounted) {
      Navigator.pop(context);
    }

  } catch (e) {
    print('Fehler beim Erstellen: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treffen erstellen'),
      ),

      body: Column(
        children: [
          nameField(),
          const SizedBox(height: 32,),
          dateTimePicker(),
          const SizedBox(height: 32,),
          locationField(),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvent,
        icon: const Icon(Icons.add),
        label: const Text('Treffen hinzufügen'),
      )
    );
  }
}