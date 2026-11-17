import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_bridge/main.dart';

void main() {
  test('reads a local or spaced WhatsApp number', () {
    expect(whatsAppDigits('0712345678'), '254712345678');
    expect(whatsAppDigits('0112345678'), '254112345678');
    expect(whatsAppDigits('+254 712 345 678'), '254712345678');
    expect(whatsAppDigits('254712345678'), '254712345678');
    expect(whatsAppDigits('abc'), isNull);
  });

  testWidgets('pastes clipboard text and clears draft', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? <String, dynamic>{'text': 'Hello from SMS 👋'}
          : null,
    );
    await tester.pumpWidget(const MaterialApp(home: ComposePage()));
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();
    expect(find.text('Hello from SMS 👋'), findsOneWidget);
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('Hello from SMS 👋'), findsNothing);
  });
  testWidgets('requires message before opening WhatsApp', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: ComposePage()));
    final send = find.text('Continue in WhatsApp');
    await tester.ensureVisible(send);
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('Paste or type a message first.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Hello');
    await tester.enterText(find.byType(TextField).last, 'abc');
    await tester.ensureVisible(send);
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('Use an international number, for example +254712345678.'),
        findsOneWidget);
  });
}
