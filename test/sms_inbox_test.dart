import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_bridge/sms_inbox_page.dart';

void main() {
  const channel = MethodChannel('message_bridge/sms');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('lists a text from the phone and opens it for editing',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        if (call.method == 'hasPermission') return true;
        if (call.method == 'list') {
          return [
            {
              'id': '7',
              'address': '+254700000001',
              'body': 'Rent is due Friday',
              'date': 1762300800000,
              'box': 'inbox',
            }
          ];
        }
        return null;
      },
    );
    await tester.pumpWidget(const MaterialApp(home: SmsInboxPage()));
    await tester.pumpAndSettle();
    expect(find.text('Rent is due Friday'), findsOneWidget);
    expect(find.text('+254700000001'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Rent is due Friday'), findsOneWidget);
  });

  testWidgets('asks before reading texts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => call.method == 'hasPermission' ? false : null,
    );
    await tester.pumpWidget(const MaterialApp(home: SmsInboxPage()));
    await tester.pumpAndSettle();
    expect(find.text('Allow SMS access'), findsOneWidget);
    expect(find.text('Rent is due Friday'), findsNothing);
  });
}
