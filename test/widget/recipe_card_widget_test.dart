import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/models/recipe.dart';
import 'package:foodly/widgets/recipe_card.dart';

void main() {
  group('RecipeCard Widget Tests', () {
    testWidgets('displays recipe title correctly', (WidgetTester tester) async {
      final recipe = Recipe(
        id: 1,
        title: 'Pasta Carbonara',
        image: 'https://example.com/image.jpg',
        possessedIngredients: ['eggs', 'bacon'],
        missingIngredients: ['cheese'],
        possessedCount: 2,
        missingCount: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pasta Carbonara'), findsOneWidget);
    });

    testWidgets('displays ingredient count correctly', (WidgetTester tester) async {
      final recipe = Recipe(
        id: 1,
        title: 'Pasta Carbonara',
        image: 'https://example.com/image.jpg',
        possessedIngredients: ['eggs', 'bacon', 'pasta'],
        missingIngredients: ['cheese', 'pepper'],
        possessedCount: 3,
        missingCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ingredients: 3/5'), findsOneWidget);
    });

    testWidgets('shows placeholder when image URL is empty', (WidgetTester tester) async {
      final recipe = Recipe(
        id: 1,
        title: 'No Image Recipe',
        image: '',
        possessedIngredients: ['ingredient1'],
        missingIngredients: ['ingredient2'],
        possessedCount: 1,
        missingCount: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('triggers onTap callback when card is tapped', (WidgetTester tester) async {
      bool tapped = false;

      final recipe = Recipe(
        id: 1,
        title: 'Pasta Carbonara',
        image: '',
        possessedIngredients: ['eggs', 'bacon', 'pasta'],
        missingIngredients: ['cheese', 'pepper'],
        possessedCount: 3,
        missingCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('card renders with proper layout structure', (WidgetTester tester) async {
      final recipe = Recipe(
        id: 1,
        title: 'Test Recipe',
        image: '',
        possessedIngredients: ['ingredient1', 'ingredient2'],
        missingIngredients: ['ingredient3', 'ingredient4', 'ingredient5'],
        possessedCount: 2,
        missingCount: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('title truncates with ellipsis when too long', (WidgetTester tester) async {
      final recipe = Recipe(
        id: 1,
        title:
            'This is a very long recipe title that should be truncated to prevent overflow issues',
        image: '',
        possessedIngredients: ['ingredient1'],
        missingIngredients: ['ingredient2'],
        possessedCount: 1,
        missingCount: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = find.byType(Text).first;
      expect(textWidget, findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.maxLines == 2 &&
              widget.overflow == TextOverflow.ellipsis,
        ),
        findsOneWidget,
      );
    });

    testWidgets('card is wrapped in Material widget for proper theming',
        (WidgetTester tester) async {
      final recipe = Recipe(
        id: 1,
        title: 'Test Recipe',
        image: '',
        possessedIngredients: ['ingredient1'],
        missingIngredients: ['ingredient2'],
        possessedCount: 1,
        missingCount: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Material), findsWidgets);
    });
  });
}
