import 'package:hive/hive.dart';

part 'food.g.dart';

@HiveType(typeId: 0)
class Food extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String? barcode;

  @HiveField(4)
  late int quantity;

  @HiveField(5)
  late String unit;

  @HiveField(6)
  late DateTime addedDate;

  @HiveField(7)
  late DateTime? expiryDate;

  Food({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit = 'g',
    this.barcode,
    DateTime? addedDate,
    this.expiryDate,
  }) : addedDate = addedDate ?? DateTime.now();

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );
    return expiryDay.difference(today).inDays;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    final daysLeft = daysUntilExpiry;
    return daysLeft != null && daysLeft < 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'barcode': barcode,
    'quantity': quantity,
    'unit': unit,
    'addedDate': addedDate.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
  };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'] as String,
    name: json['name'] as String,
    barcode: json['barcode'] as String?,
    quantity: json['quantity'] as int? ?? 1,
    unit: json['unit'] as String? ?? 'g',
    addedDate: json['addedDate'] != null
        ? DateTime.parse(json['addedDate'] as String)
        : DateTime.now(),
    expiryDate: json['expiryDate'] != null
        ? DateTime.parse(json['expiryDate'] as String)
        : null,
  );
}
