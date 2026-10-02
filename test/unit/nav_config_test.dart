import 'package:flutter_test/flutter_test.dart';
import 'package:vicoba_mobile/presentation/navigation/nav_config.dart';

void main() {
  group('NavConfig Role-Based Navigation Tests', () {
    test('MEMBER only sees permitted operational and member modules', () {
      final items = NavConfig.getNavItemsForRole('MEMBER');
      final ids = items.map((i) => i.id).toList();

      // Should include core tabs & personal operations
      expect(ids.contains('dashboard'), isTrue);
      expect(ids.contains('members'), isTrue);
      expect(ids.contains('meetings'), isTrue);
      expect(ids.contains('loans'), isTrue);
      expect(ids.contains('receipts'), isTrue);
      expect(ids.contains('cycles'), isTrue);
      expect(ids.contains('fines'), isTrue);
      expect(ids.contains('myGuarantees'), isTrue);
      expect(ids.contains('governance'), isTrue);
      expect(ids.contains('aiAdvisor'), isTrue);
      expect(ids.contains('settings'), isTrue);

      // Should NOT include leadership-only or administrative modules
      expect(ids.contains('reconciliation'), isFalse);
      expect(ids.contains('reports'), isFalse);
      expect(ids.contains('subscription'), isFalse);
      expect(ids.contains('federation'), isFalse);
      expect(ids.contains('auditLogs'), isFalse);
    });

    test('TREASURER sees financial operations and reconciliation but not audit logs', () {
      final items = NavConfig.getNavItemsForRole('TREASURER');
      final ids = items.map((i) => i.id).toList();

      expect(ids.contains('reconciliation'), isTrue);
      expect(ids.contains('reports'), isTrue);
      expect(ids.contains('subscription'), isTrue);
      expect(ids.contains('federation'), isTrue);

      // Independent supervisory audit logs are restricted
      expect(ids.contains('auditLogs'), isFalse);
    });

    test('SECRETARY sees administrative reports, federation, and audit logs but not reconciliation', () {
      final items = NavConfig.getNavItemsForRole('SECRETARY');
      final ids = items.map((i) => i.id).toList();

      expect(ids.contains('reports'), isTrue);
      expect(ids.contains('federation'), isTrue);
      expect(ids.contains('auditLogs'), isTrue);

      // Bank cash reconciliation and subscription billing are restricted
      expect(ids.contains('reconciliation'), isFalse);
      expect(ids.contains('subscription'), isFalse);
    });

    test('AUDITOR sees reconciliation, reports, and audit logs', () {
      final items = NavConfig.getNavItemsForRole('AUDITOR');
      final ids = items.map((i) => i.id).toList();

      expect(ids.contains('reconciliation'), isTrue);
      expect(ids.contains('reports'), isTrue);
      expect(ids.contains('auditLogs'), isTrue);

      // Billing management and federation are restricted
      expect(ids.contains('subscription'), isFalse);
      expect(ids.contains('federation'), isFalse);
    });

    test('CHAIRPERSON and PLATFORM_ADMIN see all modules without restriction', () {
      final chairpersonItems = NavConfig.getNavItemsForRole('CHAIRPERSON');
      final adminItems = NavConfig.getNavItemsForRole('PLATFORM_ADMIN');

      expect(chairpersonItems.length, equals(NavConfig.allNavItems.length));
      expect(adminItems.length, equals(NavConfig.allNavItems.length));
    });

    test('getRoleBadgeInfo returns correct badges for each role', () {
      final chairpersonBadge = NavConfig.getRoleBadgeInfo('CHAIRPERSON', false);
      expect(chairpersonBadge.roleKey, equals('role_CHAIRPERSON'));

      final treasurerBadge = NavConfig.getRoleBadgeInfo('TREASURER', false);
      expect(treasurerBadge.roleKey, equals('role_TREASURER'));

      final memberBadge = NavConfig.getRoleBadgeInfo('MEMBER', false);
      expect(memberBadge.roleKey, equals('role_MEMBER'));
    });
  });
}
