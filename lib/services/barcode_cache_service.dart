import 'package:hive/hive.dart';

part 'barcode_cache_service.g.dart';

@HiveType(typeId: 1)
class CachedBarcode extends HiveObject {
  @HiveField(0)
  late String barcode;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late String? brand;

  @HiveField(3)
  late DateTime cachedAt;

  CachedBarcode({
    required this.barcode,
    required this.productName,
    this.brand,
  }) : cachedAt = DateTime.now();
}

class BarcodeCacheService {
  static const String _boxName = 'barcodeCache';
  static const Duration _cacheExpiry = Duration(days: 30);
  late Box<CachedBarcode> _box;

  Future<void> init() async {
    _box = await Hive.openBox<CachedBarcode>(_boxName);
  }

  void cacheBarcode(
    String barcode,
    String productName, {
    String? brand,
  }) {
    _box.put(
      barcode,
      CachedBarcode(
        barcode: barcode,
        productName: productName,
        brand: brand,
      ),
    );
  }

  CachedBarcode? getBarcode(String barcode) {
    final cached = _box.get(barcode);
    if (cached != null) {
      final isExpired =
          DateTime.now().difference(cached.cachedAt).compareTo(_cacheExpiry) > 0;
      if (isExpired) {
        _box.delete(barcode);
        return null;
      }
    }
    return cached;
  }

  void clearCache() {
    _box.clear();
  }

  void deleteBarcode(String barcode) {
    _box.delete(barcode);
  }
}
