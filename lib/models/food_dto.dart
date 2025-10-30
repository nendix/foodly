class FoodDTO {
  final String name;
  final String? barcode;
  final String? imageUrl;
  final String? brand;

  FoodDTO({
    required this.name,
    this.barcode,
    this.imageUrl,
    this.brand,
  });

  factory FoodDTO.fromJson(Map<String, dynamic> json) {
    return FoodDTO(
      name: json['product_name'] as String? ?? json['name'] as String? ?? 'Unknown',
      barcode: json['code'] as String? ?? json['barcode'] as String?,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      brand: json['brands'] as String?,
    );
  }
}
