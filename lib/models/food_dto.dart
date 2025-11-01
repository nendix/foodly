class FoodDTO {
  final String name;
  final String? barcode;

  FoodDTO({required this.name, this.barcode});

  factory FoodDTO.fromJson(Map<String, dynamic> json) {
    return FoodDTO(
      name:
          json['product_name'] as String? ??
          json['name'] as String? ??
          'Unknown',
      barcode: json['code'] as String? ?? json['barcode'] as String?,
    );
  }
}
