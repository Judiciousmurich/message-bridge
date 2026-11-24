import 'package:flutter/material.dart';

import 'compose_page.dart';

export 'compose_page.dart';

void main() => runApp(const MessageBridge());

class MessageBridge extends StatelessWidget {
  const MessageBridge({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Message Bridge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F62)),
          scaffoldBackgroundColor: const Color(0xFFF5F7F4),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const ComposePage(),
      );
}
