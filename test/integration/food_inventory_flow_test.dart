import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/models/food.dart';

void main() {
  group('Food Inventory Integration Tests', () {
    group('Adding and Managing Foods', () {
      test('can create a food item with all properties', () {
        final food = Food(
          id: '1',
          name: 'Apple',
          quantity: 5,
          unit: 'pieces',
          barcode: '123456789',
          expiryDate: DateTime(2025, 12, 31),
        );

        expect(food.id, equals('1'));
        expect(food.name, equals('Apple'));
        expect(food.quantity, equals(5));
        expect(food.unit, equals('pieces'));
        expect(food.barcode, equals('123456789'));
        expect(food.expiryDate, equals(DateTime(2025, 12, 31)));
      });

      test('food stores current date as addedDate when not provided', () {
        final beforeCreation = DateTime.now();
        final food = Food(
          id: '1',
          name: 'Milk',
          quantity: 1,
        );
        final afterCreation = DateTime.now();

        expect(food.addedDate.isAfter(beforeCreation.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(food.addedDate.isBefore(afterCreation.add(const Duration(seconds: 1))),
            isTrue);
      });
    });

    group('Sorting Foods by Expiry Date', () {
      test('foods are sorted with earliest expiry first', () {
        final today = DateTime.now();

        final foods = [
          Food(
            id: '1',
            name: 'Item A',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 10)),
          ),
          Food(
            id: '2',
            name: 'Item B',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 5)),
          ),
          Food(
            id: '3',
            name: 'Item C',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 15)),
          ),
        ];

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('Item B'));
        expect(sorted[1].name, equals('Item A'));
        expect(sorted[2].name, equals('Item C'));
      });

      test('no-expiry foods appear at the end, sorted alphabetically', () {
        final today = DateTime.now();

        final foods = [
          Food(id: '1', name: 'Zebra', quantity: 1, expiryDate: null),
          Food(
            id: '2',
            name: 'Apple',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 5)),
          ),
          Food(id: '3', name: 'Mango', quantity: 1, expiryDate: null),
        ];

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Mango'));
        expect(sorted[2].name, equals('Zebra'));
      });

      test('items with same expiry date are sorted alphabetically', () {
        final sameDate = DateTime(2025, 12, 31);

        final foods = [
          Food(id: '1', name: 'Zebra', quantity: 1, expiryDate: sameDate),
          Food(id: '2', name: 'Apple', quantity: 1, expiryDate: sameDate),
          Food(id: '3', name: 'Mango', quantity: 1, expiryDate: sameDate),
        ];

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Mango'));
        expect(sorted[2].name, equals('Zebra'));
      });
    });

    group('Searching Foods', () {
      test('search filters foods by name case-insensitively', () {
        final foods = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
          Food(id: '3', name: 'apple juice', quantity: 2),
        ];

        final filtered = _filterFoods(foods, 'apple');

        expect(filtered, hasLength(2));
        expect(filtered[0].name, equals('Apple'));
        expect(filtered[1].name, equals('apple juice'));
      });

      test('empty search returns all foods', () {
        final foods = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterFoods(foods, '');

        expect(filtered, hasLength(2));
      });

      test('search with no matches returns empty list', () {
        final foods = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterFoods(foods, 'xyz');

        expect(filtered, isEmpty);
      });
    });

    group('Food Expiry Status', () {
      test('expired foods are correctly identified', () {
        final today = DateTime.now();

        final expiredFood = Food(
          id: '1',
          name: 'Expired Milk',
          quantity: 1,
          expiryDate: today.subtract(const Duration(days: 5)),
        );

        final freshFood = Food(
          id: '2',
          name: 'Fresh Milk',
          quantity: 1,
          expiryDate: today.add(const Duration(days: 5)),
        );

        expect(expiredFood.isExpired, isTrue);
        expect(freshFood.isExpired, isFalse);
      });

      test('days until expiry is calculated correctly', () {
        final today = DateTime.now();

        final food = Food(
          id: '1',
          name: 'Milk',
          quantity: 1,
          expiryDate: today.add(const Duration(days: 7)),
        );

        expect(food.daysUntilExpiry, equals(7));
      });

      test('food with no expiry date returns null for daysUntilExpiry', () {
        final food = Food(
          id: '1',
          name: 'Honey',
          quantity: 1,
          expiryDate: null,
        );

        expect(food.daysUntilExpiry, isNull);
      });
    });

    group('Food Serialization', () {
      test('food can be converted to JSON and back', () {
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

    group('Inventory Operations Workflow', () {
      test('complete workflow: add, search, and sort', () {
        final today = DateTime.now();

        final foods = [
          Food(id: '1', name: 'Milk', quantity: 1, expiryDate: today.add(const Duration(days: 10))),
          Food(id: '2', name: 'Cheese', quantity: 500, expiryDate: today.add(const Duration(days: 5))),
          Food(id: '3', name: 'Bread', quantity: 1, expiryDate: null),
        ];

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('Cheese'));
        expect(sorted[1].name, equals('Milk'));
        expect(sorted[2].name, equals('Bread'));

        final dairyItems = _filterFoods(sorted, 'e');

        expect(dairyItems, hasLength(2));
      });
    });
  });
}

List<Food> _sortByExpiryDate(List<Food> foods) {
  return foods
    ..sort((a, b) {
      final aExpiry = a.expiryDate;
      final bExpiry = b.expiryDate;

      if (aExpiry == null && bExpiry == null) {
        return a.name.compareTo(b.name);
      }
      if (aExpiry == null) return 1;
      if (bExpiry == null) return -1;

      final comparison = aExpiry.compareTo(bExpiry);
      if (comparison != 0) return comparison;

      return a.name.compareTo(b.name);
    });
}

List<Food> _filterFoods(List<Food> foods, String query) {
  if (query.isEmpty) {
    return foods;
  }

  return foods
      .where(
        (food) => food.name.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
}
