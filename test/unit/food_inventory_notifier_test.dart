import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/models/food.dart';

void main() {
  group('FoodInventoryNotifier Sorting Logic Tests', () {
    group('Sort by Expiry Date', () {
      test('foods with earlier expiry dates appear first', () {
        final today = DateTime.now();
        final foods = [
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

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Zebra Food'));
      });

      test('foods without expiry date appear last', () {
        final today = DateTime.now();
        final foods = [
          Food(id: '1', name: 'No Expiry', quantity: 1, expiryDate: null),
          Food(
            id: '2',
            name: 'With Expiry',
            quantity: 1,
            expiryDate: today.add(const Duration(days: 5)),
          ),
        ];

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('With Expiry'));
        expect(sorted[1].name, equals('No Expiry'));
      });

      test('foods with same expiry date sorted alphabetically', () {
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

      test('foods without expiry sorted alphabetically among themselves', () {
        final foods = [
          Food(id: '1', name: 'Zebra', quantity: 1, expiryDate: null),
          Food(id: '2', name: 'Apple', quantity: 1, expiryDate: null),
          Food(id: '3', name: 'Mango', quantity: 1, expiryDate: null),
        ];

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('Apple'));
        expect(sorted[1].name, equals('Mango'));
        expect(sorted[2].name, equals('Zebra'));
      });

      test('complex mix: expiry dates, no expiry, and alphabetical order', () {
        final today = DateTime.now();
        final foods = [
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

        final sorted = _sortByExpiryDate(foods);

        expect(sorted[0].name, equals('Banana'));
        expect(sorted[1].name, equals('Apple'));
        expect(sorted[2].name, equals('Mango'));
        expect(sorted[3].name, equals('Zebra'));
      });
    });

    group('Search Filter Logic', () {
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

      test('empty search query returns all foods', () {
        final foods = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterFoods(foods, '');

        expect(filtered, hasLength(2));
      });

      test('search returns no results for non-matching query', () {
        final foods = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Banana', quantity: 3),
        ];

        final filtered = _filterFoods(foods, 'xyz');

        expect(filtered, isEmpty);
      });

      test('search matches partial names', () {
        final foods = [
          Food(id: '1', name: 'Apple', quantity: 5),
          Food(id: '2', name: 'Pineapple', quantity: 3),
          Food(id: '3', name: 'Banana', quantity: 2),
        ];

        final filtered = _filterFoods(foods, 'apple');

        expect(filtered, hasLength(2));
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
