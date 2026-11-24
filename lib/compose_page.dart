import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Digits for a WhatsApp chat, without a leading plus.
/// A Kenyan mobile that starts with 0 is returned with country code 254.
String? whatsAppDigits(String raw) {
  var value = raw.trim().replaceAll(RegExp(r'[\s().-]'), '');
  if (value.startsWith('00')) value = '+${value.substring(2)}';
  if (RegExp(r'^0[17]\d{8}$').hasMatch(value)) {
    value = '+254${value.substring(1)}';
  }
  if (value.startsWith('+')) value = value.substring(1);
  if (!RegExp(r'^[1-9]\d{6,14}$').hasMatch(value)) return null;
  return value;
}

/// Opens the saved WhatsApp chat with no message filled in.
Future<String?> openWhatsAppNumber(String rawPhone) async {
  final digits = whatsAppDigits(rawPhone);
  if (digits == null) {
    return 'Use an international number, for example +254712345678.';
  }
  return _launchWhatsApp('phone=$digits');
}

/// Opens WhatsApp with [message] prefilled. Returns a notice when it cannot.
Future<String?> openWhatsApp(String message, String rawPhone) async {
  final text = message.trim();
  if (text.isEmpty) return 'Paste or type a message first.';
  var phone = '';
  if (rawPhone.trim().isNotEmpty) {
    final digits = whatsAppDigits(rawPhone);
    if (digits == null) {
      return 'Use an international number, for example +254712345678.';
    }
    phone = digits;
  }
  final query = 'text=${Uri.encodeComponent(text)}'
      '${phone.isEmpty ? '' : '&phone=$phone'}';
  return _launchWhatsApp(query);
}

Future<String?> _launchWhatsApp(String query) async {
  try {
    final opened = await launchUrl(
      Uri.parse('whatsapp://send?$query'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) return 'Could not open WhatsApp. Check that it is installed.';
  } catch (_) {
    return 'Could not open WhatsApp. Check that it is installed.';
  }
  return null;
}

class ComposePage extends StatefulWidget {
  const ComposePage({super.key, this.initialMessage = ''});

  final String initialMessage;

  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  late final TextEditingController _message;
  final _phone = TextEditingController();
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _message = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _message.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _notice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _paste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      if (data?.text?.isNotEmpty != true) {
        _notice('Copy a message first, then tap Paste.');
        return;
      }
      setState(() => _message.text = data!.text!);
    } catch (_) {
      _notice('Could not read the clipboard. You can type your message below.');
    }
  }

  Future<void> _copy() async {
    if (_message.text.trim().isEmpty) {
      _notice('Add a message first.');
      return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: _message.text));
      _notice('Message copied.');
    } catch (_) {
      _notice('Could not copy this message. Please try again.');
    }
  }

  Future<void> _openWhatsApp() async {
    setState(() => _opening = true);
    final notice = await openWhatsApp(_message.text, _phone.text);
    if (!mounted) return;
    if (notice != null) _notice(notice);
    setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F4),
          title: const Text('Message Bridge'),
          leading: Navigator.canPop(context)
              ? null
              : const Icon(Icons.chat_bubble_outline_rounded),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.android))
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                          'Copy a text from your Messages app (or anywhere), tap Paste, then continue in WhatsApp. This app does not read your SMS inbox.'),
                    ),
                  const SizedBox(height: 20),
                  Text('A message.\nA new destination.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              fontWeight: FontWeight.w700, height: 1.15)),
                  const SizedBox(height: 14),
                  const Text(
                      'Paste a message, make it yours, and continue the conversation on WhatsApp.'),
                  const SizedBox(height: 32),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('YOUR MESSAGE',
                            style: Theme.of(context).textTheme.labelLarge),
                        TextButton.icon(
                            onPressed: _paste,
                            icon: const Icon(Icons.content_paste_rounded),
                            label: const Text('Paste')),
                      ]),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _message,
                    minLines: 7,
                    maxLines: 12,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Your message starts here…',
                      labelText: 'Message',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_message.text.characters.length} characters'),
                        TextButton(
                            onPressed: _message.text.isEmpty
                                ? null
                                : () => setState(_message.clear),
                            child: const Text('Clear')),
                      ]),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Recipient (optional)',
                      hintText: '+254712345678',
                      helperText:
                          'Include the country code, or choose a chat in WhatsApp.',
                      helperMaxLines: 2,
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _opening ? null : _openWhatsApp,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(18)),
                    icon: const Icon(Icons.arrow_outward_rounded),
                    label: Text(_opening ? 'Opening…' : 'Continue in WhatsApp'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _copy,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16)),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy message'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                      'Review your message and tap Send in WhatsApp. Your draft stays on this screen only.',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
}
