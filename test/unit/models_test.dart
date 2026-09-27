import 'package:flutter_test/flutter_test.dart';
import 'package:vicoba_mobile/data/models/models.dart';

void main() {
  group('Data Models Parsing Tests', () {
    test('Member.fromJson parses valid JSON correctly', () {
      final json = {
        'id': 'mem-1',
        'fullName': 'Amina Salum',
        'phone': '+255712345678',
        'role': 'TREASURER',
        'sharesCount': 15,
        'voluntarySavingsBalance': 150000.0,
        'activeLoanBalance': 50000.0,
        'status': 'ACTIVE',
      };

      final member = Member.fromJson(json);

      expect(member.id, 'mem-1');
      expect(member.fullName, 'Amina Salum');
      expect(member.phone, '+255712345678');
      expect(member.role, 'TREASURER');
      expect(member.sharesCount, 15);
      expect(member.voluntarySavingsBalance, 150000.0);
      expect(member.activeLoanBalance, 50000.0);
      expect(member.status, 'ACTIVE');
    });

    test('Loan.fromJson parses status and balances accurately', () {
      final json = {
        'id': 'loan-101',
        'memberId': 'mem-1',
        'memberName': 'Baraka Mwangi',
        'principalAmount': 500000.0,
        'interestRate': 10.0,
        'totalRepayable': 550000.0,
        'balanceRemaining': 350000.0,
        'status': 'ACTIVE',
        'durationMonths': 3,
        'applicationDate': '2026-09-01T10:00:00Z',
      };

      final loan = Loan.fromJson(json);

      expect(loan.id, 'loan-101');
      expect(loan.memberName, 'Baraka Mwangi');
      expect(loan.principalAmount, 500000.0);
      expect(loan.balanceRemaining, 350000.0);
      expect(loan.status, 'ACTIVE');
      expect(loan.durationMonths, 3);
    });

    test('Receipt.fromJson parses cryptographic verification details', () {
      final json = {
        'id': 'rec-55',
        'receiptType': 'SHARE_PURCHASE',
        'amount': 20000.0,
        'receiptNumber': 'RCP-2026-00055',
        'digitalSignatureHash': '0x8f2a9c3d4e1b7f02a6c8e9d1c2b3a4f5',
        'memberName': 'Devotha Temu',
      };

      final receipt = Receipt.fromJson(json);

      expect(receipt.id, 'rec-55');
      expect(receipt.type, 'SHARE_PURCHASE');
      expect(receipt.amount, 20000.0);
      expect(receipt.receiptNumber, 'RCP-2026-00055');
      expect(receipt.digitalSignatureHash, '0x8f2a9c3d4e1b7f02a6c8e9d1c2b3a4f5');
      expect(receipt.memberName, 'Devotha Temu');
    });
  });
}
