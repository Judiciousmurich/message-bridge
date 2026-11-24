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