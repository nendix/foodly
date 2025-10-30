class Recipe {
  final int id;
  final String title;
  final String image;
  final List<String> possessedIngredients;
  final List<String> missingIngredients;
  final int possessedCount;
  final int missingCount;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.possessedIngredients,
    required this.missingIngredients,
    required this.possessedCount,
    required this.missingCount,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final possessedIng = (json['usedIngredients'] as List?)
        ?.map((e) => e['original'] as String)
        .toList() ?? [];
    final missingIng = (json['missedIngredients'] as List?)
        ?.map((e) => e['original'] as String)
        .toList() ?? [];

    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String,
      possessedIngredients: possessedIng,
      missingIngredients: missingIng,
      possessedCount: json['usedIngredientCount'] as int? ?? 0,
      missingCount: json['missedIngredientCount'] as int? ?? 0,
    );
  }
}
