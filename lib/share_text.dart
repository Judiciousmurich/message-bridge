import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.actserv.message_bridge/share');

/// M-Pesa SMS text shared from another app (e.g. Messages → Share).
Future<String?> consumeSharedPlainText() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  try {
    final text = await _channel.invokeMethod<String>('consumeSharedText');
    final trimmed = text?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  } on PlatformException {
    return null;
  }
}