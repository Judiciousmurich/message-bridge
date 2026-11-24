/// One parsed M-Pesa payment SMS (treasurer adds these by pasting, not by reading SMS).
class MpesaContribution {
  const MpesaContribution({
    required this.firstName,
    required this.lastName,
    required this.amountKes,
    required this.rawSms,
    this.phoneRaw,
    this.phoneDigits,
  });

  final String firstName;
  final String lastName;
  final double amountKes;
  final String? phoneRaw;
  /// WhatsApp-ready digits (no plus), when the SMS included a Kenyan mobile.
  final String? phoneDigits;
  final String rawSms;

  String get displayName => '$firstName $lastName'.trim();

  String formatAmount() => formatKes(amountKes);
}

String formatKes(double amount) {
  final whole = amount == amount.roundToDouble();
  final text = whole ? amount.toInt().toString() : amount.toStringAsFixed(2);
  return 'Ksh $text';
}

class MpesaParseResult {
  const MpesaParseResult.ok(this.contribution)
      : error = null;
  const MpesaParseResult.fail(this.error) : contribution = null;

  final MpesaContribution? contribution;
  final String? error;

  bool get isOk => contribution != null;
}

/// Parses Safaricom M-Pesa "money received" SMS text the treasurer pasted.
MpesaParseResult parseMpesaSms(String raw) {
  final text = raw.trim();
  if (text.length < 20) {
    return const MpesaParseResult.fail(
      'Paste the full M-Pesa confirmation SMS from Messages.',
    );
  }

  final amount = _parseAmount(text);
  if (amount == null) {
    return const MpesaParseResult.fail(
      'Could not find an amount (look for Ksh… in the SMS).',
    );
  }

  final namePhone = _parseNameAndPhone(text);
  if (namePhone == null) {
    return const MpesaParseResult.fail(
      'Could not find payer name and number. Paste the received-from SMS, not a sent payment.',
    );
  }

  final parts = namePhone.name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) {
    return const MpesaParseResult.fail('Could not read the payer name.');
  }
  final first = parts.first;
  final last = parts.length > 1 ? parts.last : '';

  String? digits;
  if (namePhone.phone != null) {
    digits = _phoneToWhatsAppDigits(namePhone.phone!);
  }

  return MpesaParseResult.ok(MpesaContribution(
    firstName: _titleCase(first),
    lastName: _titleCase(last),
    amountKes: amount,
    phoneRaw: namePhone.phone,
    phoneDigits: digits,
    rawSms: text,
  ));
}

double? _parseAmount(String text) {
  final patterns = [
    RegExp(r'(?:Ksh|KES)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    RegExp(r'received\s+([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
  ];
  for (final re in patterns) {
    final match = re.firstMatch(text);
    if (match != null) {
      final n = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (n != null && n > 0) return n;
    }
  }
  return null;
}

class _NamePhone {
  _NamePhone(this.name, this.phone);
  final String name;
  final String? phone;
}

_NamePhone? _parseNameAndPhone(String text) {
  final patterns = [
    RegExp(
      r'received\s+from\s+(.+?)\s+(0[17]\d{8}|254[17]\d{8})\b',
      caseSensitive: false,
    ),
    RegExp(
      r"from\s+([A-Za-z][A-Za-z0-9\s.&'-]{1,60}?)\s+(0[17]\d{8}|254[17]\d{8})\b",
      caseSensitive: false,
    ),
    RegExp(
      r"from\s+([A-Za-z][A-Za-z0-9\s.&'-]{1,60}?)\s+on\b",
      caseSensitive: false,
    ),
  ];
  for (final re in patterns) {
    final match = re.firstMatch(text);
    if (match == null) continue;
    final name = match.group(1)!.trim();
    final phone = match.groupCount >= 2 ? match.group(2) : null;
    if (name.length >= 2) return _NamePhone(name, phone);
  }
  return null;
}

String? _phoneToWhatsAppDigits(String phone) {
  var p = phone.trim();
  if (p.startsWith('0') && p.length == 10) {
    p = '254${p.substring(1)}';
  }
  if (RegExp(r'^254[17]\d{8}$').hasMatch(p)) return p;
  return null;
}

String _titleCase(String word) {
  if (word.isEmpty) return word;
  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}

/// Formatted lines for the WhatsApp group treasurer post.
String buildGroupUpdate({
  required String fundraiserTitle,
  required List<MpesaContribution> entries,
}) {
  final title =
      fundraiserTitle.trim().isEmpty ? 'Fundraiser' : fundraiserTitle.trim();
  final buffer = StringBuffer('$title\n\n');
  for (final e in entries) {
    buffer.writeln('${e.displayName} — ${e.formatAmount()}');
  }
  final total = entries.fold<double>(0, (s, e) => s + e.amountKes);
  buffer.write('\nTotal: ${formatKes(total)}');
  return buffer.toString();
}

String thankYouMessage({
  required MpesaContribution entry,
  required String fundraiserTitle,
}) {
  final title =
      fundraiserTitle.trim().isEmpty ? 'our group fundraiser' : fundraiserTitle;
  final name =
      entry.firstName.isNotEmpty ? entry.firstName : entry.displayName;
  return 'Asante $name. We recorded your ${entry.formatAmount()} for $title. '
      '— Treasurer (Message Bridge)';
}