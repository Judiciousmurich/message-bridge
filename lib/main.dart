import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'automation_page.dart';

void main() => runApp(const MessageBridge());

class MessageBridge extends StatelessWidget {
  const MessageBridge({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Message Bridge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F62)),
          scaffoldBackgroundColor: const Color(0xFFF5F7F4),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? const AutomationPage()
            : const ComposePage(),
      );
}

class ComposePage extends StatefulWidget {
  const ComposePage({super.key});

  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  final _message = TextEditingController();
  final _phone = TextEditingController();
  bool _opening = false;
  bool _smsEnabled = false;
  static const _sms = MethodChannel('message_bridge/sms');

  @override
  void initState() {
    super.initState();
    _sms.setMethodCallHandler((call) async {
      if (call.method != 'incomingSms' || !mounted) return;
      final text = call.arguments as String;
      if (_message.text.trim().isEmpty) {
        setState(() => _message.text = text);
        _notice('Incoming SMS added to your draft.');
      } else {
        final replace = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('New SMS received'),
                  content: const Text(
                      'Replace your current draft with the incoming message?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Keep draft')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Use SMS')),
                  ],
                ));
        if (replace == true && mounted) setState(() => _message.text = text);
      }
    });
  }

  Future<void> _toggleSms(bool enable) async {
    try {
      if (enable) {
        final allowed = await _sms.invokeMethod<bool>('enable') ?? false;
        if (mounted) setState(() => _smsEnabled = allowed);
        if (!allowed) {
          _notice(
              'SMS permission was not granted. You can still paste a message.');
        }
      } else {
        await _sms.invokeMethod<void>('disable');
        if (mounted) setState(() => _smsEnabled = false);
      }
    } catch (_) {
      _notice('SMS reading is unavailable on this device.');
    }
  }

  @override
  void dispose() {
    _sms.setMethodCallHandler(null);
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
    final message = _message.text.trim();
    if (message.isEmpty) {
      _notice('Paste or type a message first.');
      return;
    }
    final rawPhone = _phone.text.trim();
    final phone = rawPhone.replaceAll(RegExp(r'[\s()+-]'), '');
    if (rawPhone.isNotEmpty && !RegExp(r'^[1-9]\d{6,14}$').hasMatch(phone)) {
      _notice('Use an international number, for example +254712345678.');
      return;
    }
    setState(() => _opening = true);
    final query = 'text=${Uri.encodeComponent(message)}'
        '${phone.isEmpty ? '' : '&phone=$phone'}';
    try {
      final opened = await launchUrl(
        Uri.parse('whatsapp://send?$query'),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        _notice('Could not open WhatsApp. Check that it is installed.');
      }
    } catch (_) {
      _notice('Could not open WhatsApp. Check that it is installed.');
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F4),
          title: const Text('Message Bridge'),
          leading: const Icon(Icons.chat_bubble_outline_rounded),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (!kIsWeb &&
                      defaultTargetPlatform == TargetPlatform.android)
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Read incoming SMS'),
                      subtitle: const Text(
                          'Allow SMS access to import new messages while this app is running. Stops when the app closes.'),
                      value: _smsEnabled,
                      onChanged: _toggleSms,
                    ),
                  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                    const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                            'On iPhone, copy your message and tap Paste to import it.')),
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
