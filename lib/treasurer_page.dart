import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'compose_page.dart';
import 'mpesa_parser.dart';

class TreasurerPage extends StatefulWidget {
  const TreasurerPage({super.key});

  @override
  State<TreasurerPage> createState() => _TreasurerPageState();
}

class _TreasurerPageState extends State<TreasurerPage> {
  final _fundraiser = TextEditingController(text: 'Group fundraiser');
  final List<MpesaContribution> _entries = [];
  bool _openingWhatsApp = false;

  @override
  void dispose() {
    _fundraiser.dispose();
    super.dispose();
  }

  double get _total => _entries.fold(0, (s, e) => s + e.amountKes);

  void _notice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pasteMpesa() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text?.trim().isEmpty != false) {
      _notice('Copy an M-Pesa received SMS from Messages, then tap Paste.');
      return;
    }
    final result = parseMpesaSms(data!.text!);
    if (!result.isOk) {
      _notice(result.error!);
      return;
    }
    setState(() => _entries.insert(0, result.contribution!));
    _notice('Added ${result.contribution!.displayName} — '
        '${result.contribution!.formatAmount()}');
  }

  void _removeAt(int index) {
    setState(() => _entries.removeAt(index));
  }

  Future<void> _copyGroupUpdate() async {
    if (_entries.isEmpty) {
      _notice('Add at least one M-Pesa payment first.');
      return;
    }
    final text = buildGroupUpdate(
      fundraiserTitle: _fundraiser.text,
      entries: List.of(_entries.reversed),
    );
    await Clipboard.setData(ClipboardData(text: text));
    _notice('Group update copied. Paste it in your WhatsApp group.');
  }

  Future<void> _openGroupUpdateInWhatsApp() async {
    if (_entries.isEmpty) {
      _notice('Add at least one M-Pesa payment first.');
      return;
    }
    setState(() => _openingWhatsApp = true);
    final text = buildGroupUpdate(
      fundraiserTitle: _fundraiser.text,
      entries: List.of(_entries.reversed),
    );
    final notice = await openWhatsApp(text, '');
    if (!mounted) return;
    if (notice != null) _notice(notice);
    setState(() => _openingWhatsApp = false);
  }

  Future<void> _thankPayer(MpesaContribution entry) async {
    final msg = thankYouMessage(
      entry: entry,
      fundraiserTitle: _fundraiser.text,
    );
    setState(() => _openingWhatsApp = true);
    final phone = entry.phoneDigits ?? '';
    final notice = await openWhatsApp(msg, phone);
    if (!mounted) return;
    if (notice != null) {
      _notice(notice);
    } else if (phone.isEmpty) {
      _notice('No number in SMS—pick the payer in WhatsApp.');
    }
    setState(() => _openingWhatsApp = false);
  }

  String _totalLabel() {
    final whole = _total == _total.roundToDouble();
    final text = whole ? _total.toInt().toString() : _total.toStringAsFixed(2);
    return 'Ksh $text';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F4),
          title: const Text('Treasurer'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ComposePage(),
                ),
              ),
              child: const Text('Compose'),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'WhatsApp group treasurer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Copy each M-Pesa “received” SMS from your Messages app. '
                    'We read only what you paste—no SMS permission. '
                    'Then post totals to your WhatsApp group and thank payers.',
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _fundraiser,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Fundraiser name',
                      hintText: 'e.g. Wedding chama',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFFE8F5F0),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total collected',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            _totalLabel(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pasteMpesa,
                    icon: const Icon(Icons.content_paste_rounded),
                    label: const Text('Paste M-Pesa SMS'),
                  ),
                  const SizedBox(height: 20),
                  if (_entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No payments yet. When someone pays via M-Pesa, '
                        'open the SMS in Messages, copy it, and paste here.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...List.generate(_entries.length, (i) {
                      final e = _entries[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(e.displayName),
                          subtitle: Text(
                            '${e.formatAmount()}'
                            '${e.phoneRaw != null ? ' • ${e.phoneRaw}' : ''}',
                          ),
                          isThreeLine: false,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'remove') _removeAt(i);
                              if (value == 'thank') _thankPayer(e);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'thank',
                                child: Text('Thank in WhatsApp'),
                              ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Text('Remove'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _entries.isEmpty ? null : _copyGroupUpdate,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy group update'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _entries.isEmpty || _openingWhatsApp
                        ? null
                        : _openGroupUpdateInWhatsApp,
                    icon: const Icon(Icons.groups_rounded),
                    label: Text(_openingWhatsApp
                        ? 'Opening…'
                        : 'Share update in WhatsApp'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'You choose the WhatsApp group or contact and tap Send. '
                    'Message Bridge does not read your inbox or send messages for you.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}