import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bridge_look.dart';
import 'compose_page.dart';
import 'sms_inbox_page.dart';

export 'compose_page.dart';

void main() => runApp(const MessageBridge());

class MessageBridge extends StatelessWidget {
  const MessageBridge({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Message Bridge',
        debugShowCheckedModeBanner: false,
        theme: BridgeLook.theme(),
        home: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? const SmsInboxPage()
            : const ComposePage(),
      );
}
