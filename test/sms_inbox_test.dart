import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_bridge/sms_inbox_page.dart';

void main() {
  test('bundles today oldest first and leaves other days out', () {
    final todayEarly = DateTime(2026, 11, 17, 8).millisecondsSinceEpoch;
    final todayLate = DateTime(2026, 11, 17, 18).millisecondsSinceEpoch;
    final yesterday = DateTime(2026, 11, 16, 12).millisecondsSinceEpoch;
    final messages = [
      PhoneText(
        id: '2',
        address: '+254700000002',
        body: 'Later today',
        dateMillis: todayLate,
        sent: false,
      ),
      PhoneText(
        id: '1',
        address: '+254700000001',
        body: 'Yesterday note',
        dateMillis: yesterday,
        sent: true,
      ),
      PhoneText(
        id: '3',
        address: '+254700000003',
        body: 'Earlier today',
        dateMillis: todayEarly,
        sent: false,
      ),
    ];
    final todays = textsOnDay(messages, DateTime(2026, 11, 17, 21));
    expect(todays.map((message) => message.body),
        ['Earlier today', 'Later today']);
    final bundled = bundleTexts(todays);
    expect(bundled.indexOf('Earlier today'), lessThan(bundled.indexOf('Later today')));
    expect(bundled.contains('Yesterday note'), isFalse);
  });

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

  testWidgets('a 07 number is accepted when a text is tapped', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final saved = <String>[];
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
        if (call.method == 'setRecipient') {
          saved.add((call.arguments as Map)['number'] as String);
        }
        return null;
      },
    );
    await tester.pumpWidget(const MaterialApp(home: SmsInboxPage()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0712345678');
    await tester.ensureVisible(find.text('Open in WhatsApp'));
    await tester.tap(find.text('Open in WhatsApp'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Add your WhatsApp number above, then tap the text.'),
        findsNothing);
    expect(saved.last, '+254712345678');
  });

  testWidgets('copies every listed text', (tester) async {
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
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await tester.pumpWidget(const MaterialApp(home: SmsInboxPage()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Copy all texts'));
    await tester.tap(find.text('Copy all texts'));
    await tester.pumpAndSettle();
    expect(copied, contains('Rent is due Friday'));
    expect(find.text('All texts copied.'), findsOneWidget);
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
