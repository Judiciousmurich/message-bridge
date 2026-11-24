import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'compose_page.dart';
import 'mpesa_parser.dart';
import 'share_text.dart';
import 'treasurer_store.dart';

class TreasurerPage extends StatefulWidget {
  const TreasurerPage({super.key});

  @override
  State<TreasurerPage> createState() => _TreasurerPageState();
}

class _TreasurerPageState extends State<TreasurerPage> {
  final _fundraiser = TextEditingController(text: 'Group fundraiser');
  final List<MpesaContribution> _entries = [];
  bool _openingWhatsApp = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _fundraiser.addListener(_persistQuietly);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final data = await TreasurerStore.load();
    if (!mounted) return;
    setState(() {
      _fundraiser.text = data.title;
      _entries
        ..clear()
        ..addAll(data.entries);
      _loaded = true;
    });
    await _ingestSharedOrClipboard();
  }

  Future<void> _ingestSharedOrClipboard() async {
    final shared = await consumeSharedPlainText();
    if (shared != null) {
      await _ingestSmsText(shared, source: 'Shared M-Pesa SMS');
    }
  }

  Future<void> _persistQuietly() async {
    if (!_loaded) return;
    await TreasurerStore.save(
      fundraiserTitle: _fundraiser.text,
      entries: _entries,
    );
  }

  @override
  void dispose() {
    _fundraiser.removeListener(_persistQuietly);
    _fundraiser.dispose();
    super.dispose();
  }

  double get _total => _entries.fold(0, (s, e) => s + e.amountKes);

  void _notice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _persist() => _persistQuietly();

  Future<void> _ingestSmsText(String text, {required String source}) async {
    final result = parseMpesaSms(text);
    if (!result.isOk) {
      _notice(result.error!);
      return;
    }
    await _addEntry(result.contribution!, source);
  }

  Future<void> _addEntry(MpesaContribution entry, String source) async {
    if (_isDuplicate(entry)) {
      _notice('That payment looks like a duplicate. Skipped.');
      return;
    }
    setState(() => _entries.insert(0, entry));
    await _persist();
    _notice('$source: ${entry.displayName} — ${entry.formatAmount()}');
  }

  bool _isDuplicate(MpesaContribution entry) {
    for (final e in _entries) {
      if (e.amountKes == entry.amountKes &&
          e.displayName.toLowerCase() == entry.displayName.toLowerCase() &&
          (e.phoneDigits ?? '') == (entry.phoneDigits ?? '')) {
        return true;
      }
    }
    return false;
  }

  Future<void> _pasteMpesa() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text?.trim().isEmpty != false) {
      _notice('Copy an M-Pesa received SMS from Messages, then tap Paste.');
      return;
    }
    await _ingestSmsText(data!.text!, source: 'Added');
  }

  Future<void> _manualAdd() async {
    final first = TextEditingController();
    final last = TextEditingController();
    final amount = TextEditingController();
    final phone = TextEditingController();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add payment manually'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: first,
                decoration: const InputDecoration(labelText: 'First name'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: last,
                decoration: const InputDecoration(labelText: 'Surname'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (KES)',
                  hintText: '500',
                ),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: '0712345678',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final kes = double.tryParse(amount.text.replaceAll(',', '').trim());
    if (kes == null || kes <= 0) {
      _notice('Enter a valid amount.');
      return;
    }
    if (first.text.trim().isEmpty) {
      _notice('Enter at least a first name.');
      return;
    }
    final entry = MpesaContribution.manual(
      firstName: first.text,
      lastName: last.text,
      amountKes: kes,
      phoneRaw: phone.text,
    );
    await _addEntry(entry, 'Manual');
    first.dispose();
    last.dispose();
    amount.dispose();
    phone.dispose();
  }

  Future<void> _removeAt(int index) async {
    setState(() => _entries.removeAt(index));
    await _persist();
  }

  Future<void> _clearFundraiser() async {
    if (_entries.isEmpty && _fundraiser.text.trim() == 'Group fundraiser') {
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start new fundraiser?'),
        content: const Text(
          'This clears saved payments on this phone. '
          'Your WhatsApp messages are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _entries.clear();
      _fundraiser.text = 'Group fundraiser';
    });
    await TreasurerStore.clear();
    _notice('Fundraiser cleared.');
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
      _notice('No number—pick the payer in WhatsApp.');
    }
    setState(() => _openingWhatsApp = false);
  }

  String _totalLabel() {
    final whole = _total == _total.roundToDouble();
    final text = whole ? _total.toInt().toString() : _total.toStringAsFixed(2);
    return 'Ksh $text';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F4),
        title: const Text('Treasurer'),
        actions: [
          IconButton(
            tooltip: 'New fundraiser',
            onPressed: _clearFundraiser,
            icon: const Icon(Icons.refresh_rounded),
          ),
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
                  'Copy or Share each M-Pesa SMS from Messages (Share → Message Bridge). '
                  'We never read your SMS inbox. Totals stay on this phone.',
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
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _manualAdd,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Add payment manually'),
                ),
                const SizedBox(height: 20),
                if (_entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No payments yet. In Messages, open an M-Pesa SMS, tap Share, '
                      'choose Message Bridge—or copy and paste here.',
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
                  'Nothing is sent automatically.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}