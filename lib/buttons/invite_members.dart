import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class InviteButton extends StatelessWidget {
  final String eventId;

  const new({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => showDialog(
        context: context, 
        builder: (context) => InviteCode(eventId: eventId)), 
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(
          color: Colors.black87,
        )
      ),
      child: Icon(
        PhosphorIcons.shareFat(),
      ),
    );
  }
}

class InviteCode extends StatefulWidget {
  final String eventId;

  const new({
    super.key,
    required this.eventId,
  });

  @override
  State<InviteCode> createState() => _InviteCodeState();
}

class _InviteCodeState extends State<InviteCode> {

  String inviteCode = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    inviteMembers(widget.eventId);
  }

  String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> inviteMembers(String eventId) async {
    try {
      final data = await Supabase.instance.client
          .from('events')
          .select('invite_code')
          .eq('id', eventId)
          .maybeSingle();

      if (data == null) {
        debugPrint('Event nicht gefunden');
        return;
      }

      String code = data['invite_code'] ?? generateInviteCode();

      if (data['invite_code'] == null) {
        await Supabase.instance.client
            .from('events')
            .update({
              'invite_code': code,
            })
            .eq('id', eventId);
      }

      if (!mounted) return;

      setState(() {
        inviteCode = code;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Code speichern fehlgeschlagen: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Treffen einladen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Teile diesen Code mit anderen:'),
          const SizedBox(height: 16),

          if (isLoading)
            const CircularProgressIndicator()
          else
            SelectableText(
              inviteCode,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: isLoading
              ? null
              : () async {
                  await Clipboard.setData(
                    ClipboardData(text: inviteCode),
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code kopiert!'),
                    ),
                  );
                },
          icon: const Icon(Icons.copy),
          label: const Text('Kopieren'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}