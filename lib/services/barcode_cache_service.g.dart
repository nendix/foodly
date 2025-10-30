// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_cache_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedBarcodeAdapter extends TypeAdapter<CachedBarcode> {
  @override
  final int typeId = 1;

  @override
  CachedBarcode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedBarcode(
      barcode: fields[0] as String,
      productName: fields[1] as String,
      brand: fields[2] as String?,
    )..cachedAt = fields[3] as DateTime;
  }

  @override
  void write(BinaryWriter writer, CachedBarcode obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedBarcodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
