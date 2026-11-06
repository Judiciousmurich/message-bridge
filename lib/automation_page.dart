import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AutomationPage extends StatefulWidget {
  const AutomationPage({super.key});

  @override
  State<AutomationPage> createState() => _AutomationPageState();
}

class _AutomationPageState extends State<AutomationPage>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('message_bridge/automation');
  final _form = GlobalKey<FormState>();
  final _account = TextEditingController();
  final _token = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _sender = TextEditingController();
  bool _enabled = false;
  bool _busy = true;
  bool _hasToken = false;
  bool _saved = false;
  String _status = 'Loading forwarding settings…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy) {
      _refreshStatus();
    }
  }

  void _error(Object error) {
    final message = error is PlatformException
        ? error.message ?? 'Could not update forwarding.'
        : 'Could not connect to Android forwarding.';
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadSettings() async {
    try {
      final data = await _channel.invokeMapMethod<String, dynamic>('status');
      if (!mounted || data == null) return;
      _account.text = data['account'] as String? ?? '';
      _from.text = data['from'] as String? ?? '';
      _to.text = data['to'] as String? ?? '';
      _sender.text = data['sender'] as String? ?? '';
      setState(() {
        _enabled = data['enabled'] == true;
        _hasToken = data['hasToken'] == true;
        _saved = _hasToken;
        _status = data['status'] as String? ?? 'No SMS processed yet.';
      });
    } catch (error) {
      _error(error);
      if (mounted) setState(() => _status = 'Forwarding settings unavailable.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshStatus() async {
    try {
      final data = await _channel.invokeMapMethod<String, dynamic>('status');
      if (!mounted || data == null) return;
      setState(() {
        _enabled = data['enabled'] == true;
        _status = data['status'] as String? ?? _status;
        if (_enabled && data['permission'] != true) {
          _status =
              'SMS permission was removed. Pause, then enable forwarding to grant access again.';
        }
      });
    } catch (error) {
      _error(error);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await _channel.invokeMethod<void>('save', {
        'account': _account.text.trim(),
        'token': _token.text.trim(),
        'from': _from.text.trim(),
        'to': _to.text.trim(),
        'sender': _sender.text.trim(),
      });
      if (!mounted) return;
      _token.clear();
      setState(() {
        _hasToken = true;
        _saved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Connection saved. Enable automatic forwarding below.')));
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggle(bool enable) async {
    setState(() => _busy = true);
    try {
      final allowed =
          enable ? await _channel.invokeMethod<bool>('enable') ?? false : false;
      if (!enable) await _channel.invokeMethod<void>('disable');
      if (!mounted) return;
      setState(() => _enabled = allowed);
      if (enable && !allowed) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('SMS permission is required for automatic forwarding.')));
      }
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _edited(String _) {
    if (_saved) setState(() => _saved = false);
  }

  String? _number(String? value) =>
      RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(value?.trim() ?? '')
          ? null
          : 'Enter an international number such as +254712345678';

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final field in [_account, _token, _from, _to, _sender]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Message Bridge'), actions: [
          IconButton(
              onPressed: _busy ? null : _refreshStatus,
              tooltip: 'Refresh status',
              icon: const Icon(Icons.refresh)),
        ]),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('SMS to WhatsApp.\nAutomatically.',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 16),
                  const Text(
                      'Connect once, choose your WhatsApp number, and enable forwarding. Each new SMS is sent in the background, including while the app is closed or the phone is locked. The text stays in the phone\'s Messages app.'),
                  const SizedBox(height: 24),
                  Text('WhatsApp test connection',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                      'Use your Twilio WhatsApp Sandbox details. The recipient must join the Sandbox and send it a WhatsApp message to open a 24-hour test session. Messages come from that Sandbox number.'),
                  const SizedBox(height: 20),
                  TextFormField(
                      controller: _account,
                      enabled: !_enabled && !_busy,
                      onChanged: _edited,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          labelText: 'Twilio Account SID', hintText: 'AC…'),
                      validator: (value) => RegExp(r'^AC[a-fA-F0-9]{32}$')
                              .hasMatch(value?.trim() ?? '')
                          ? null
                          : 'Enter your Account SID'),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _token,
                      enabled: !_enabled && !_busy,
                      onChanged: _edited,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                          labelText: 'Twilio auth token',
                          hintText: _hasToken
                              ? 'Saved securely. Leave blank to keep.'
                              : 'Enter token on this phone'),
                      validator: (value) =>
                          _hasToken || (value?.trim().isNotEmpty ?? false)
                              ? null
                              : 'Enter the auth token'),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _from,
                      enabled: !_enabled && !_busy,
                      onChanged: _edited,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Twilio WhatsApp sender',
                          hintText: '+1415…'),
                      validator: _number),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _to,
                      enabled: !_enabled && !_busy,
                      onChanged: _edited,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Forward to WhatsApp number',
                          hintText: '+254…'),
                      validator: _number),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _sender,
                      enabled: !_enabled && !_busy,
                      onChanged: _edited,
                      decoration: const InputDecoration(
                          labelText: 'Only from SMS sender (optional)',
                          helperText:
                              'Exact sender number or name. Blank forwards all new SMS.',
                          helperMaxLines: 2)),
                  const SizedBox(height: 20),
                  FilledButton(
                      onPressed: _enabled || _busy ? null : _save,
                      child: const Text('Save connection')),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Automatic forwarding'),
                      subtitle: const Text(
                          'While enabled, matching SMS text is sent to Twilio and the WhatsApp recipient above.'),
                      value: _enabled,
                      onChanged:
                          _busy || (!_saved && !_enabled) ? null : _toggle),
                  const SizedBox(height: 16),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  _enabled
                                      ? 'Forwarding enabled'
                                      : 'Forwarding paused',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(_status),
                            ],
                          ))),
                  const SizedBox(height: 12),
                  const Text(
                      'Internet is required. Android may delay background work. Force-stopping the app stops SMS reception until you reopen it. Pausing discards pending messages; a submission already in progress may finish.'),
                  if (_busy)
                    const Padding(
                        padding: EdgeInsets.all(16),
                        child: LinearProgressIndicator()),
                ],
              )),
        ))),
      );
}
