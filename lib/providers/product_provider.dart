import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/mock_data_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  String _selectedCategory = 'Tất cả';
  String _selectedCertification = 'Tất cả';
  String _searchQuery = '';
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  String get selectedCategory => _selectedCategory;
  String get selectedCertification => _selectedCertification;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  ProductProvider() {
    loadProducts();
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
    return _products.where((p) {
      final matchCategory = _selectedCategory == 'Tất cả' || p.category == _selectedCategory;
      final matchCert = _selectedCertification == 'Tất cả' || p.certification == _selectedCertification;
      final matchQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.region.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchCert && matchQuery;
    }).toList();
  }

  List<ProductModel> get featuredProducts {
    return _products.where((p) => p.isFeatured).toList();
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
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProduct(ProductModel product) async {
    _products.insert(0, product);
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> updateProduct(ProductModel product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  void deductStock(String productId, int quantity) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index];
      final newQty = (current.stockQuantity - quantity).clamp(0, 99999);
      _products[index] = current.copyWith(stockQuantity: newQty);
      StorageService.saveProducts(_products);
      notifyListeners();
    }
  }
}

