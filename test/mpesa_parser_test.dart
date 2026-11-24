import 'package:flutter_test/flutter_test.dart';
import 'package:message_bridge/mpesa_parser.dart';

void main() {
  test('parses confirmed received SMS', () {
    const sms = '''
Confirmed. Ksh1,250.00 received from JOHN MICHAEL DOE 0712345678 on 24/11/26 at 10:00 AM
New M-Pesa balance is Ksh5,000.00''';
    final r = parseMpesaSms(sms);
    expect(r.isOk, isTrue);
    expect(r.contribution!.amountKes, 1250);
    expect(r.contribution!.firstName, 'John');
    expect(r.contribution!.lastName, 'Doe');
    expect(r.contribution!.phoneDigits, '254712345678');
  });

  test('parses you have received wording', () {
    const sms =
        'You have received Ksh500.00 from Jane Wanjiru 254712345678 on 11/24/26';
    final r = parseMpesaSms(sms);
    expect(r.isOk, isTrue);
    expect(r.contribution!.amountKes, 500);
    expect(r.contribution!.firstName, 'Jane');
    expect(r.contribution!.lastName, 'Wanjiru');
  });

  test('rejects sent payment without payer', () {
    const sms = 'Confirmed. Ksh100.00 sent to PAYBILL 123456 for account 1';
    final r = parseMpesaSms(sms);
    expect(r.isOk, isFalse);
  });

  test('manual entry and json round-trip', () {
    final entry = MpesaContribution.manual(
      firstName: 'mary',
      lastName: 'k',
      amountKes: 200,
      phoneRaw: '0711111111',
    );
    expect(entry.firstName, 'Mary');
    expect(entry.phoneDigits, '254711111111');
    final back = MpesaContribution.fromJson(entry.toJson());
    expect(back.amountKes, 200);
    expect(back.displayName, entry.displayName);
  });

  test('group update lists entries and total', () {
    final entries = [
      const MpesaContribution(
        firstName: 'A',
        lastName: 'B',
        amountKes: 100,
        rawSms: '',
      ),
      const MpesaContribution(
        firstName: 'C',
        lastName: 'D',
        amountKes: 250,
        rawSms: '',
      ),
    ];
    final text = buildGroupUpdate(fundraiserTitle: 'Chama', entries: entries);
    expect(text, contains('Chama'));
    expect(text, contains('A B — Ksh 100'));
    expect(text, contains('Total: Ksh 350'));
  });
}