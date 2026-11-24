import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'mpesa_parser.dart';

const _kFundraiserTitle = 'treasurer_fundraiser_title';
const _kEntriesJson = 'treasurer_entries_json';

/// On-device fundraiser data only (Play-safe; not uploaded).
class TreasurerStore {
  static Future<({String title, List<MpesaContribution> entries})> load() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_kFundraiserTitle) ?? 'Group fundraiser';
    final raw = prefs.getString(_kEntriesJson);
    if (raw == null || raw.isEmpty) {
      return (title: title, entries: <MpesaContribution>[]);
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final entries = list
          .map((e) => MpesaContribution.fromJson(e as Map<String, dynamic>))
          .toList();
      return (title: title, entries: entries);
    } catch (_) {
      return (title: title, entries: <MpesaContribution>[]);
    }
  }

  static Future<void> save({
    required String fundraiserTitle,
    required List<MpesaContribution> entries,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFundraiserTitle, fundraiserTitle);
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kEntriesJson, encoded);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFundraiserTitle);
    await prefs.remove(_kEntriesJson);
  }
}