class Recipe {
  final int id;
  final String title;
  final String image;
  final List<String> usedIngredients;
  final List<String> missedIngredients;
  final int usedIngredientCount;
  final int missedIngredientCount;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.usedIngredients,
    required this.missedIngredients,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final usedIng = (json['usedIngredients'] as List?)
        ?.map((e) => e['original'] as String)
        .toList() ?? [];
    final missedIng = (json['missedIngredients'] as List?)
        ?.map((e) => e['original'] as String)
        .toList() ?? [];

    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String,
      usedIngredients: usedIng,
      missedIngredients: missedIng,
      usedIngredientCount: json['usedIngredientCount'] as int? ?? 0,
      missedIngredientCount: json['missedIngredientCount'] as int? ?? 0,
    );
  }
}
