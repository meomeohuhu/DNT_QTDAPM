import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  static const voucherCode = 'FRESH20';
  static const voucherMinimum = 200000.0;
  static const voucherDiscount = 20000.0;

  final List<CartItemModel> _items = [];
  bool _voucherSelected = false;

  bool get hasVoucher => _voucherSelected && subtotal >= voucherMinimum;

  void toggleVoucher() {
    if (subtotal < voucherMinimum) return;
    _voucherSelected = !_voucherSelected;
    notifyListeners();
  }

  List<CartItemModel> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shippingFee {
    if (_items.isEmpty) return 0.0;
    // Free shipping for orders over 300,000 VND
    return subtotal >= 300000 ? 0.0 : 25000.0;
  }

  double get discountAmount {
    final bulkDiscount = subtotal >= 400000 ? 30000.0 : 0.0;
    return bulkDiscount + (hasVoucher ? voucherDiscount : 0.0);
  }

  double get totalAmount => (subtotal + shippingFee - discountAmount).clamp(0.0, double.infinity);

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItemModel(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _items[index].quantity = newQuantity;
      if (subtotal < voucherMinimum) _voucherSelected = false;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    if (subtotal < voucherMinimum) _voucherSelected = false;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _voucherSelected = false;
    notifyListeners();
  }
}

