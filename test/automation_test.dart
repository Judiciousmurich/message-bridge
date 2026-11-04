import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_bridge/main.dart';

void main() {
  testWidgets(
      'Android starts with forwarding setup and enables after permission',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('message_bridge/automation'), (call) async {
      calls.add(call.method);
      if (call.method == 'status') {
        return {
          'enabled': false,
          'permission': false,
          'hasToken': true,
          'account': 'AC${List.filled(32, 'a').join()}',
          'from': '+14155238886',
          'to': '+254712345678',
          'sender': '',
          'status': 'No SMS processed yet.',
        };
      }
      if (call.method == 'enable') return true;
      return null;
    });
    await tester.pumpWidget(const MessageBridge());
    await tester.pumpAndSettle();
    expect(find.text('SMS to WhatsApp.\nAutomatically.'), findsOneWidget);
    expect(find.text('Paste'), findsNothing);
    expect(calls,
        ['status']); // Merely opening the app must not enable forwarding.
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(calls, ['status', 'enable']);
    expect(find.text('Forwarding enabled'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(calls.last, 'disable');
    expect(find.text('Forwarding paused'), findsOneWidget);
  });

  testWidgets('permission denial keeps automatic forwarding off',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('message_bridge/automation'), (call) async {
      if (call.method == 'status') return {'hasToken': true, 'enabled': false};
      if (call.method == 'enable') return false;
      return null;
    });
    await tester.pumpWidget(const MessageBridge());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Forwarding paused'), findsOneWidget);
    expect(find.text('SMS permission is required for automatic forwarding.'),
        findsOneWidget);
  });
}
