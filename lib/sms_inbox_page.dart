import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'compose_page.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
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
      if (!mounted) return;
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

  Future<void> _send(PhoneText message) async {
    if (_opening) return;
    setState(() => _opening = true);
    final notice = await openWhatsApp(message.body, '');
    if (!mounted) return;
    if (notice != null) _notice(notice);
    setState(() => _opening = false);
  }

  void _edit(PhoneText message) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ComposePage(initialMessage: message.body),
      ),
    );
  }

  String _when(int millis) {
    if (millis <= 0) return '';
    final time = DateTime.fromMillisecondsSinceEpoch(millis);
    final month = '${time.month}'.padLeft(2, '0');
    final day = '${time.day}'.padLeft(2, '0');
    final hour = '${time.hour}'.padLeft(2, '0');
    final minute = '${time.minute}'.padLeft(2, '0');
    return '$day/$month/${time.year} $hour:$minute';
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
            IconButton(
              tooltip: 'Type a message',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ComposePage()),
              ),
              icon: const Icon(Icons.edit_outlined),
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
                              'Message Bridge reads the SMS messages already stored on this Android phone. Choose one to open it in WhatsApp, then tap Send there.'),
                          const SizedBox(height: 20),
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
                                        '${message.sent ? 'Sent' : 'Received'} · ${_when(message.dateMillis)}'),
                                    const SizedBox(height: 8),
                                    Text(message.body),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () => _edit(message),
                                          child: const Text('Edit'),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: _opening
                                              ? null
                                              : () => _send(message),
                                          child: const Text(
                                              'Continue in WhatsApp'),
                                        ),
                                      ],
                                    ),
                                  ],
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
