import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/models/food.dart';

void main() {
  group('PantryNotifier Sorting Logic Tests', () {
    group('Sort by Expiry Date', () {
      test('items with earlier expiry dates appear first', () {
        final today = DateTime.now();
        final items = [
          Food(
            id: '1',
            name: 'Zebra Food',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 10)),
          ),
          Food(
            id: '2',
            name: 'Apple',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 5)),
          ),
        ];

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Zebra Food'));
      });

      test('items without expiry date appear last', () {
        final today = DateTime.now();
        final items = [
          Food(id: '1', name: 'No Expiry', quantity: 1, expiryDate: null),
          Food(
            id: '2',
            name: 'With Expiry',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 5)),
          ),
        ];

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('With Expiry'));
        expect(sorted[1].name, equals('No Expiry'));
      });

      test('items with same expiry date sorted alphabetically', () {
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

      test('items without expiry sorted alphabetically among themselves', () {
        final items = [
          Food(id: '1', name: 'Zebra', quantity: 1, expiryDate: null),
          Food(id: '2', name: 'Apple', quantity: 1, expiryDate: null),
          Food(id: '3', name: 'Mango', quantity: 1, expiryDate: null),
        ];

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Mango'));
        expect(sorted[2].name, equals('Zebra'));
      });

      test('complex mix: expiry dates, no expiry, and alphabetical order', () {
        final today = DateTime.now();
        final items = [
          Food(id: '1', name: 'Zebra', quantity: 1, expiryDate: null),
          Food(
            id: '2',
            name: 'Apple',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 10)),
          ),
          Food(id: '3', name: 'Mango', quantity: 1, expiryDate: null),
          Food(
            id: '4',
            name: 'Banana',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 5)),
          ),
        ];

        final sorted = _sortByExpiryDate(items);

        expect(sorted[0].name, equals('Banana'));
        expect(sorted[1].name, equals('Apple'));
        expect(sorted[2].name, equals('Mango'));
        expect(sorted[3].name, equals('Zebra'));
      });
    });

    group('Search Filter Logic', () {
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

      test('empty search query returns all items', () {
        final items = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterItems(items, '');

        expect(filtered, hasLength(2));
      });

      test('search returns no results for non-matching query', () {
        final items = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterItems(items, 'xyz');

        expect(filtered, isEmpty);
      });

      test('search matches partial names', () {
        final items = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Pineapple', quantity: 3),
          Food(id: '3', name: 'Banana', quantity: 2),
        ];

        final filtered = _filterItems(items, 'apple');

        expect(filtered, hasLength(2));
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
