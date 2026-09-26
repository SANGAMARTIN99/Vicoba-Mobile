import 'package:flutter_test/flutter_test.dart';
import 'package:vicoba_mobile/core/utils/formatters.dart';

void main() {
  group('Formatters Tests', () {
    test('Formatters.currency formats numbers with TZS prefix and commas', () {
      expect(Formatters.currency(50000), 'TZS 50,000');
      expect(Formatters.currency(1500000), 'TZS 1,500,000');
      expect(Formatters.currency(0), 'TZS 0');
    });

    test('Formatters.compact formats large numbers cleanly', () {
      expect(Formatters.compact(12500000), '12.5M');
      expect(Formatters.compact(450000), '450K');
    });

    test('Formatters.truncateHash truncates long hash signatures', () {
      const hash = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      final truncated = Formatters.truncateHash(hash);
      expect(truncated.contains('...'), isTrue);
      expect(truncated.length, lessThan(hash.length));
    });

    test('Formatters.percent formats percentages', () {
      expect(Formatters.percent(10.5), '10.5%');
      expect(Formatters.percent(12), '12.0%');
    });

    test('Formatters.date formats DateTime strings properly', () {
      final date = DateTime(2026, 10, 2);
      expect(Formatters.date(date), '02 Oct 2026');
    });
  });
}
