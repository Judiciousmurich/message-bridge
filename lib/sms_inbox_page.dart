import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'compose_page.dart';

const whatsAppDraftLimit = 1500;

String formatTextTime(int millis) {
  if (millis <= 0) return '';
  final time = DateTime.fromMillisecondsSinceEpoch(millis);
  final month = '${time.month}'.padLeft(2, '0');
  final day = '${time.day}'.padLeft(2, '0');
  final hour = '${time.hour}'.padLeft(2, '0');
  final minute = '${time.minute}'.padLeft(2, '0');
  return '$day/$month/${time.year} $hour:$minute';
}

/// Oldest text first, so a batch reads in order.
String joinedTexts(List<PhoneText> messages) {
  final ordered = [...messages]..sort((a, b) => a.dateMillis.compareTo(b.dateMillis));
  return [
    for (final message in ordered)
      '${message.address}\n${message.sent ? 'Sent' : 'Received'} · ${formatTextTime(message.dateMillis)}\n${message.body}',
  ].join('\n\n');
}

class PhoneText {
  const PhoneText({
    required this.id,
    required this.address,
    required this.body,
    required this.dateMillis,
    required this.sent,
  });

  final String id;
  final String address;
  final String body;
  final int dateMillis;
  final bool sent;

  factory PhoneText.fromMap(Map<dynamic, dynamic> data) => PhoneText(
        id: '${data['id']}',
        address: (data['address'] as String?)?.trim().isNotEmpty == true
            ? data['address'] as String
            : 'Unknown sender',
        body: data['body'] as String? ?? '',
        dateMillis: (data['date'] as num?)?.toInt() ?? 0,
        sent: data['box'] == 'sent',
      );
}

class SmsInboxPage extends StatefulWidget {
  const SmsInboxPage({super.key});

  @override
  State<SmsInboxPage> createState() => _SmsInboxPageState();
}

class _SmsInboxPageState extends State<SmsInboxPage> {
  static const _channel = MethodChannel('message_bridge/sms');
  static const _limit = 200;

  var _loading = true;
  var _needsPermission = false;
  var _opening = false;
  String? _error;
  List<PhoneText> _messages = const [];
  final _whatsappNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _whatsappNumber.dispose();
    super.dispose();
  }

  void _notice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final granted = await _channel.invokeMethod<bool>('hasPermission') ?? false;
      final saved = await _channel.invokeMethod<String>('getRecipient') ?? '';
      if (!mounted) return;
      if (_whatsappNumber.text.isEmpty) _whatsappNumber.text = saved;
      if (!granted) {
        setState(() {
          _needsPermission = true;
          _messages = const [];
          _loading = false;
        });
        return;
      }
      final rows = await _channel.invokeListMethod<dynamic>('list') ?? const [];
      if (!mounted) return;
      setState(() {
        _needsPermission = false;
        _messages = [
          for (final row in rows)
            if (row is Map) PhoneText.fromMap(row),
        ];
        _loading = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _needsPermission = error.code == 'permission';
        _error = error.message ?? 'Could not read the texts on this phone.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not read the texts on this phone.';
      });
    }
  }

  Future<void> _allow() async {
    setState(() => _loading = true);
    try {
      final granted =
          await _channel.invokeMethod<bool>('requestPermission') ?? false;
      if (!mounted) return;
      if (!granted) {
        setState(() {
          _loading = false;
          _needsPermission = true;
        });
        _notice('SMS access is still off. Allow it in the phone settings.');
        return;
      }
      await _load();
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _notice(error.message ?? 'Could not request SMS access.');
    }
  }

  Future<void> _openSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } on PlatformException catch (error) {
      _notice(error.message ?? 'Could not open settings.');
    }
  }

  Future<void> _rememberNumber(String value) async {
    try {
      await _channel.invokeMethod<void>('setRecipient', {'number': value.trim()});
    } catch (_) {}
  }

  Future<void> _send(PhoneText message) async {
    if (_opening) return;
    final digits = whatsAppDigits(_whatsappNumber.text);
    if (digits == null) {
      _notice(_whatsappNumber.text.trim().isEmpty
          ? 'Add your WhatsApp number above, then tap the text.'
          : 'Use the country code, for example +254712345678.');
      return;
    }
    final number = '+$digits';
    if (_whatsappNumber.text != number) {
      _whatsappNumber.value = TextEditingValue(
        text: number,
        selection: TextSelection.collapsed(offset: number.length),
      );
    }
    setState(() => _opening = true);
    await _rememberNumber(number);
    final notice = await openWhatsApp(message.body, number);
    if (!mounted) return;
    if (notice != null) _notice(notice);
    setState(() => _opening = false);
  }

  Future<void> _copyAll() async {
    if (_messages.isEmpty) {
      _notice('No texts to copy.');
      return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: joinedTexts(_messages)));
      _notice('Copied ${_messages.length} texts.');
    } catch (_) {
      _notice('Could not copy these texts.');
    }
  }

  Future<void> _sendAll() async {
    if (_opening || _messages.isEmpty) return;
    final digits = whatsAppDigits(_whatsappNumber.text);
    if (digits == null) {
      _notice(_whatsappNumber.text.trim().isEmpty
          ? 'Add your WhatsApp number above, then tap the text.'
          : 'Use the country code, for example +254712345678.');
      return;
    }
    final number = '+$digits';
    if (_whatsappNumber.text != number) {
      _whatsappNumber.value = TextEditingValue(
        text: number,
        selection: TextSelection.collapsed(offset: number.length),
      );
    }
    final draft = joinedTexts(_messages);
    setState(() => _opening = true);
    await _rememberNumber(number);
    String? notice;
    if (draft.length <= whatsAppDraftLimit) {
      notice = await openWhatsApp(draft, number);
    } else {
      try {
        await Clipboard.setData(ClipboardData(text: draft));
        notice = await openWhatsAppNumber(number);
        notice ??=
            'Copied ${_messages.length} texts. Paste them in WhatsApp, then tap Send.';
      } catch (_) {
        notice = 'Could not copy these texts.';
      }
    }
    if (!mounted) return;
    if (notice != null) _notice(notice);
    setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F4),
          title: const Text('Message Bridge'),
          actions: [
            IconButton(
              tooltip: 'Refresh texts',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          Text('Texts on this phone.',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1.15)),
                          const SizedBox(height: 14),
                          const Text(
                              'Tap one text to open it. Or send every listed text together. You tap Send once in WhatsApp.'),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _whatsappNumber,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Your WhatsApp number',
                              hintText: '+254712345678',
                              helperText:
                                  'Saved on this phone. 07… is read as +254.',
                              helperMaxLines: 2,
                              prefixIcon: Icon(Icons.chat_rounded),
                            ),
                            onChanged: (value) {
                              _rememberNumber(value);
                            },
                          ),
                          const SizedBox(height: 20),
                          if (_messages.isNotEmpty) ...[
                            OutlinedButton.icon(
                              onPressed: _opening ? null : _copyAll,
                              icon: const Icon(Icons.copy_rounded),
                              label: const Text('Copy all texts'),
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: _opening ? null : _sendAll,
                              icon: const Icon(Icons.arrow_outward_rounded),
                              label: Text(
                                  'Open all ${_messages.length} in WhatsApp'),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (_needsPermission) ...[
                            const Text(
                                'Allow SMS access so the texts can be listed here. They stay on this phone.'),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _allow,
                              child: const Text('Allow SMS access'),
                            ),
                            TextButton(
                              onPressed: _openSettings,
                              child: const Text('Open settings'),
                            ),
                          ],
                          if (_error != null) ...[
                            Text(_error!),
                            const SizedBox(height: 12),
                          ],
                          if (!_needsPermission &&
                              _error == null &&
                              _messages.isEmpty)
                            const Text('No text messages were found on this phone.'),
                          if (_messages.length == _limit)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('Showing the 200 newest texts.'),
                            ),
                          for (final message in _messages) ...[
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _opening ? null : () => _send(message),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(message.address,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${message.sent ? 'Sent' : 'Received'} · ${formatTextTime(message.dateMillis)}'),
                                      const SizedBox(height: 8),
                                      Text(message.body),
                                      const SizedBox(height: 8),
                                      Text('Open in WhatsApp',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                  color: const Color(0xFF087F62))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ),
      );
}
