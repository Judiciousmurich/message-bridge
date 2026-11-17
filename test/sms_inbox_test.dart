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

  testWidgets('tapping a text opens it in the saved WhatsApp chat',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        calls.add(call.method);
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
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel(
          'dev.flutter.pigeon.url_launcher_android.UrlLauncherApi.launchUrl'),
      (call) async => null,
    );
    await tester.pumpWidget(const MaterialApp(home: SmsInboxPage()));
    await tester.pumpAndSettle();
    expect(find.text('Rent is due Friday'), findsOneWidget);
    expect(find.text('+254700000001'), findsOneWidget);
    expect(find.text('Continue in WhatsApp'), findsNothing);
    await tester.enterText(find.byType(TextField), '+254712345678');
    await tester.ensureVisible(find.text('Open in WhatsApp'));
    await tester.tap(find.text('Open in WhatsApp'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls.where((call) => call == 'setRecipient').length, 2);
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

  testWidgets('says when the phone has no texts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        if (call.method == 'hasPermission') return true;
        if (call.method == 'list') return <Map<String, Object>>[];
        return null;
      },
    );
    await tester.pumpWidget(const MaterialApp(home: SmsInboxPage()));
    await tester.pumpAndSettle();
    expect(find.text('No texts on this phone.'), findsOneWidget);
    expect(find.text('Open in WhatsApp'), findsNothing);
  });
}
