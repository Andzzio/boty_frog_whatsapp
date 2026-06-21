import 'dart:math';
import 'package:boty_frog/domain/datasources/product_datasource.dart';
import 'package:boty_frog/domain/entities/product_entity.dart';
import 'package:boty_frog/domain/repos/product_repository.dart';

/// Implementation of [ProductRepository] with fuzzy search.
class ProductRepositoryImpl implements ProductRepository {
  /// Constructs a [ProductRepositoryImpl] with the given datasource.
  ProductRepositoryImpl(this._datasource);

  final ProductDatasource _datasource;

  @override
  Future<List<ProductEntity>> searchProducts({
    required String businessId,
    required String query,
  }) async {
    final allProducts = await _datasource.getProducts(businessId);
    final normalizedQuery = _normalize(query);

    if (normalizedQuery.isEmpty) return [];

    final matches = <_ProductMatch>[];
    final queryWords = normalizedQuery
        .split(' ')
        .where((w) => w.length > 2)
        .toList();
    final effectiveQueryWords = queryWords.isEmpty
        ? normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList()
        : queryWords;

    for (final product in allProducts) {
      final normalizedName = _normalize(product.name);

      if (normalizedName.contains(normalizedQuery)) {
        matches.add(_ProductMatch(product, 1));
        continue;
      }

      final productWords = normalizedName
          .split(' ')
          .where((w) => w.isNotEmpty)
          .toList();
      var matchedWordsCount = 0;
      var totalSimilarity = 0.0;

      for (final qWord in effectiveQueryWords) {
        var bestWordSim = 0.0;
        for (final pWord in productWords) {
          final sim = _calculateSimilarity(qWord, pWord);
          if (sim > bestWordSim) {
            bestWordSim = sim;
          }
        }
        if (bestWordSim >= 0.75) {
          matchedWordsCount++;
          totalSimilarity += bestWordSim;
        }
      }

      if (effectiveQueryWords.isNotEmpty &&
          matchedWordsCount == effectiveQueryWords.length) {
        final averageSimilarity = totalSimilarity / effectiveQueryWords.length;
        matches.add(_ProductMatch(product, averageSimilarity));
      }
    }

    matches.sort((a, b) => b.similarity.compareTo(a.similarity));

    return matches.map((m) => m.product).toList();
  }

  String _normalize(String input) {
    var output = input.toLowerCase().trim();
    final accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    for (final entry in accents.entries) {
      output = output.replaceAll(entry.key, entry.value);
    }
    return output;
  }

  double _calculateSimilarity(String s, String t) {
    if (s == t) return 1;
    if (s.isEmpty || t.isEmpty) return 0;

    final dist = _levenshtein(s, t);
    final maxLength = max(s.length, t.length);
    return 1 - (dist / maxLength);
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);

    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = _min3(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }
      for (var k = 0; k < v0.length; k++) {
        v0[k] = v1[k];
      }
    }
    return v0[t.length];
  }

  int _min3(int a, int b, int c) {
    final m = a < b ? a : b;
    return m < c ? m : c;
  }
}

class _ProductMatch {
  _ProductMatch(this.product, this.similarity);
  final ProductEntity product;
  final double similarity;
}
