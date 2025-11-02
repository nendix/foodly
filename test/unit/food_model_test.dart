import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/models/food.dart';

void main() {
  group('Food Model Tests', () {
    group('daysUntilExpiry', () {
      test('returns null when expiryDate is null', () {
        final food = Food(
          id: '1',
          name: 'Apple',
          quantity: 5,
          expiryDate: null,
        );
        expect(food.daysUntilExpiry, isNull);
      });

      test('returns correct days until expiry for future date', () {
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 5));
        final food = Food(
          id: '1',
          name: 'Milk',
          quantity: 1,
          expiryDate: futureDate,
        );
        expect(food.daysUntilExpiry, equals(5));
      });

      test('returns 0 when expiry date is today', () {
        final today = DateTime.now();
        final todayAtMidnight = DateTime(today.year, today.month, today.day);
        final food = Food(
          id: '1',
          name: 'Bread',
          quantity: 1,
          expiryDate: todayAtMidnight,
        );
        expect(food.daysUntilExpiry, equals(0));
      });

      test('returns negative days when expired', () {
        final now = DateTime.now();
        final pastDate = now.subtract(const Duration(days: 3));
        final food = Food(
          id: '1',
          name: 'Yogurt',
          quantity: 1,
          expiryDate: pastDate,
        );
        expect(food.daysUntilExpiry, lessThan(0));
      });
    });

    group('isExpired', () {
      test('returns false when expiryDate is null', () {
        final food = Food(
          id: '1',
          name: 'Apple',
          quantity: 5,
          expiryDate: null,
        );
        expect(food.isExpired, isFalse);
      });

      test('returns false when expiry date is in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 5));
        final food = Food(
          id: '1',
          name: 'Milk',
          quantity: 1,
          expiryDate: futureDate,
        );
        expect(food.isExpired, isFalse);
      });

      test('returns false when expiry date is today', () {
        final today = DateTime.now();
        final todayAtMidnight = DateTime(today.year, today.month, today.day);
        final food = Food(
          id: '1',
          name: 'Bread',
          quantity: 1,
          expiryDate: todayAtMidnight,
        );
        expect(food.isExpired, isFalse);
      });

      test('returns true when expiry date is in the past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final food = Food(
          id: '1',
          name: 'Yogurt',
          quantity: 1,
          expiryDate: pastDate,
        );
        expect(food.isExpired, isTrue);
      });
    });

    group('JSON serialization', () {
      test('toJson returns correct map', () {
        final expiryDate = DateTime(2025, 12, 31);
        final addedDate = DateTime(2025, 1, 1);
        final food = Food(
          id: '1',
          name: 'Apple',
          quantity: 5,
          unit: 'pieces',
          barcode: '123456789',
          addedDate: addedDate,
          expiryDate: expiryDate,
        );

        final json = food.toJson();

        expect(json['id'], equals('1'));
        expect(json['name'], equals('Apple'));
        expect(json['quantity'], equals(5));
        expect(json['unit'], equals('pieces'));
        expect(json['barcode'], equals('123456789'));
        expect(json['addedDate'], equals(addedDate.toIso8601String()));
        expect(json['expiryDate'], equals(expiryDate.toIso8601String()));
      });

      test('fromJson creates Food object correctly', () {
        final addedDate = DateTime(2025, 1, 1);
        final expiryDate = DateTime(2025, 12, 31);
        final json = {
          'id': '1',
          'name': 'Apple',
          'quantity': 5,
          'unit': 'pieces',
          'barcode': '123456789',
          'addedDate': addedDate.toIso8601String(),
          'expiryDate': expiryDate.toIso8601String(),
        };

        final food = Food.fromJson(json);

        expect(food.id, equals('1'));
        expect(food.name, equals('Apple'));
        expect(food.quantity, equals(5));
        expect(food.unit, equals('pieces'));
        expect(food.barcode, equals('123456789'));
        expect(food.addedDate, equals(addedDate));
        expect(food.expiryDate, equals(expiryDate));
      });

      test('fromJson handles null expiryDate', () {
        final json = {
          'id': '1',
          'name': 'Apple',
          'quantity': 5,
          'unit': 'g',
        };

        final food = Food.fromJson(json);

        expect(food.id, equals('1'));
        expect(food.name, equals('Apple'));
        expect(food.expiryDate, isNull);
      });

      test('roundtrip: toJson then fromJson preserves data', () {
        final original = Food(
          id: '1',
          name: 'Banana',
          quantity: 10,
          unit: 'pieces',
          barcode: '987654321',
          expiryDate: DateTime(2025, 6, 15),
        );

        final json = original.toJson();
        final restored = Food.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.quantity, equals(original.quantity));
        expect(restored.unit, equals(original.unit));
        expect(restored.barcode, equals(original.barcode));
        expect(restored.expiryDate, equals(original.expiryDate));
      });
    });
  });
}
