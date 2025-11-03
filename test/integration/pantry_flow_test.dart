import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/models/food.dart';

void main() {
  group('Pantry Integration Tests', () {
    group('Adding and Managing Items', () {
      test('can create a food item with all properties', () {
        final item = Food(
          id: '1',
          name: 'Apple',
          quantity: 5,
          unit: 'pieces',
          barcode: '123456789',
          expiryDate: DateTime(2025, 12, 31),
        );

        expect(item.id, equals('1'));
        expect(item.name, equals('Apple'));
        expect(item.quantity, equals(5));
        expect(item.unit, equals('pieces'));
        expect(item.barcode, equals('123456789'));
        expect(item.expiryDate, equals(DateTime(2025, 12, 31)));
      });

      test('item stores current date as addedDate when not provided', () {
        final beforeCreation = DateTime.now();
        final item = Food(
          id: '1',
          name: 'Milk',
          quantity: 1,
        );
        final afterCreation = DateTime.now();

        expect(item.addedDate.isAfter(beforeCreation.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(item.addedDate.isBefore(afterCreation.add(const Duration(seconds: 1))),
            isTrue);
      });
    });

    group('Sorting Items by Expiry Date', () {
      test('items are sorted with earliest expiry first', () {
        final today = DateTime.now();

        final items = [
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

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('Item B'));
        expect(sorted[1].name, equals('Item A'));
        expect(sorted[2].name, equals('Item C'));
      });

      test('no-expiry items appear at the end, sorted alphabetically', () {
        final today = DateTime.now();

        final items = [
          Food(id: '1', name: 'Zebra', quantity: 1, expiryDate: null),
          Food(
            id: '2',
            name: 'Apple',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 5)),
          ),
          Food(id: '3', name: 'Mango', quantity: 1, expiryDate: null),
        ];

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Mango'));
        expect(sorted[2].name, equals('Zebra'));
      });

      test('items with same expiry date are sorted alphabetically', () {
        final sameDate = DateTime(2025, 12, 31);

        final items = [
          Food(id: '1', name: 'Zebra', quantity: 1, expiryDate: sameDate),
          Food(id: '2', name: 'Apple', quantity: 1, expiryDate: sameDate),
          Food(id: '3', name: 'Mango', quantity: 1, expiryDate: sameDate),
        ];

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Mango'));
        expect(sorted[2].name, equals('Zebra'));
      });
    });

    group('Searching Items', () {
      test('search filters items by name case-insensitively', () {
        final items = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
          Food(id: '3', name: 'apple juice', quantity: 2),
        ];

        final filtered = _filterItems(items, 'apple');

        expect(filtered, hasLength(2));
        expect(filtered[0].name, equals('Apple'));
        expect(filtered[1].name, equals('apple juice'));
      });

      test('empty search returns all items', () {
        final items = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterItems(items, '');

        expect(filtered, hasLength(2));
      });

      test('search with no matches returns empty list', () {
        final items = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterItems(items, 'xyz');

        expect(filtered, isEmpty);
      });
    });

    group('Item Expiry Status', () {
      test('expired items are correctly identified', () {
        final today = DateTime.now();

        final expiredItem = Food(
          id: '1',
          name: 'Expired Milk',
          quantity: 1,
          expiryDate: today.subtract(const Duration(days: 5)),
        );

        final freshItem = Food(
          id: '2',
          name: 'Fresh Milk',
          quantity: 1,
          expiryDate: today.add(const Duration(days: 5)),
        );

        expect(expiredItem.isExpired, isTrue);
        expect(freshItem.isExpired, isFalse);
      });

      test('days until expiry is calculated correctly', () {
        final today = DateTime.now();

        final item = Food(
          id: '1',
          name: 'Milk',
          quantity: 1,
          expiryDate: today.add(const Duration(days: 7)),
        );

        expect(item.daysUntilExpiry, equals(7));
      });

      test('item with no expiry date returns null for daysUntilExpiry', () {
        final item = Food(
          id: '1',
          name: 'Honey',
          quantity: 1,
          expiryDate: null,
        );

        expect(item.daysUntilExpiry, isNull);
      });
    });

    group('Item Serialization', () {
      test('item can be converted to JSON and back', () {
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

    group('Pantry Operations Workflow', () {
      test('complete workflow: add, search, and sort', () {
        final today = DateTime.now();

        final items = [
          Food(id: '1', name: 'Milk', quantity: 1, expiryDate: today.add(const Duration(days: 10))),
          Food(id: '2', name: 'Cheese', quantity: 500, expiryDate: today.add(const Duration(days: 5))),
          Food(id: '3', name: 'Bread', quantity: 1, expiryDate: null),
        ];

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('Cheese'));
        expect(sorted[1].name, equals('Milk'));
        expect(sorted[2].name, equals('Bread'));

        final dairyItems = _filterItems(sorted, 'e');

        expect(dairyItems, hasLength(2));
      });
    });
  });
}

List<Food> _sortByExpiryDate(List<Food> items) {
  return items
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

List<Food> _filterItems(List<Food> items, String query) {
  if (query.isEmpty) {
    return items;
  }

  return items
      .where(
        (item) => item.name.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
}
