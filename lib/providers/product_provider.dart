import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'order_provider.dart';
import '../services/mock_data_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  String _selectedCategory = 'Tất cả';
  String _selectedCertification = 'Tất cả';
  String _searchQuery = '';
  bool _isLoading = false;

  final OrderProvider _orders;
  late final Future<void> loadCompletion;

  List<ProductModel> get products => _products.map(_availableProduct).toList();

  ProductModel _availableProduct(ProductModel product) {
    final available = product.stockQuantity - _orders.reservedQuantity(product.id);
    return product.copyWith(stockQuantity: available < 0 ? 0 : available);
  }
  String get selectedCategory => _selectedCategory;
  String get selectedCertification => _selectedCertification;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  ProductProvider(this._orders) {
    _orders.addListener(notifyListeners);
    loadCompletion = loadProducts();
  }

  @override
  void dispose() {
    _orders.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    // 1. Try loading from Firestore if connected
    final firestoreProducts = await FirebaseService.getProductsFromFirestore();
    if (firestoreProducts != null && firestoreProducts.isNotEmpty) {
      _products = firestoreProducts;
    } else {
      // 2. Try loading from Local Storage
      final cached = await StorageService.getProducts();
      if (cached != null && cached.isNotEmpty) {
        _products = cached;
      } else {
        // 3. Fallback to rich Mock Data
        _products = MockDataService.getMockProducts();
        await StorageService.saveProducts(_products);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  List<String> get categories {
    final Set<String> cats = {'Tất cả'};
    for (var p in _products) {
      cats.add(p.category);
    }
    return cats.toList();
  }

  List<String> get certifications {
    return ['Tất cả', 'VietGAP', 'GlobalGAP', 'Organic USDA', 'OCOP 4 Sao'];
  }

  List<ProductModel> get filteredProducts {
    return products.where((p) {
      final matchCategory = _selectedCategory == 'Tất cả' || p.category == _selectedCategory;
      final matchCert = _selectedCertification == 'Tất cả' || p.certification == _selectedCertification;
      final matchQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.region.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchCert && matchQuery;
    }).toList();
  }

  List<ProductModel> get featuredProducts {
    return products.where((p) => p.isFeatured).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCertification(String cert) {
    _selectedCertification = cert;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  ProductModel? getProductById(String id) {
    try {
      return _availableProduct(_products.firstWhere((p) => p.id == id));
    } catch (_) {
      return null;
    }
  }

  Future<bool> adjustStock(String productId, int change) {
    return _orders.runInventoryOperation(() async {
      await loadCompletion;
      final index = _products.indexWhere((product) => product.id == productId);
      if (index == -1) return false;
      final product = _products[index];
      if (_availableProduct(product).stockQuantity + change < 0) return false;
      final updated = [..._products]..[index] = product.copyWith(
        stockQuantity: product.stockQuantity + change,
      );
      await StorageService.saveProducts(updated);
      _products = updated;
      notifyListeners();
      return true;
    });
  }
}
