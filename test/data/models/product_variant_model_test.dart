import 'package:boty_frog/data/models/product_variant_model.dart';
import 'package:test/test.dart';

void main() {
  group('ProductVariantModel.fromJson', () {
    test('parses new list-of-maps sizes schema and computes total stock', () {
      final variant = ProductVariantModel.fromJson({
        'sku': 'SKU-1',
        'name': 'Negro',
        'color': 4278190080,
        'stock': 0,
        'price': 89,
        'sizes': [
          {'size': 'S', 'stock': 2, 'sku': 'SKU-1-S'},
          {'size': 'M', 'stock': 5, 'sku': 'SKU-1-M'},
        ],
      });

      expect(variant.stock, equals(7));
      expect(variant.sizes, equals(['S (stock: 2)', 'M (stock: 5)']));
      expect(variant.price, equals(89.0));
    });

    test('parses legacy list-of-strings sizes schema', () {
      final variant = ProductVariantModel.fromJson({
        'name': 'Azul',
        'stock': 4,
        'price': 55.5,
        'sizes': ['S', 'M', 'L'],
      });

      expect(variant.stock, equals(4));
      expect(variant.sizes, equals(['S', 'M', 'L']));
    });
  });
}
