import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/batch_model.dart';
import '../models/product_model.dart';

class StorageService {
  static const String _keyActiveRole = 'active_role';
  static const String _keyOrders = 'cached_orders';
  static const String _keyBatches = 'cached_batches';
  static const String _keyProducts = 'cached_products';

  static Future<void> saveActiveRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveRole, role.name);
  }

  static Future<UserRole> getActiveRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleStr = prefs.getString(_keyActiveRole);
    if (roleStr != null) {
      return UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.customer,
      );
    }
    return UserRole.customer;
  }

  static Future<void> saveOrders(List<OrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final list = orders.map((o) => jsonEncode(o.toMap())).toList();
    if (!await prefs.setStringList(_keyOrders, list)) {
      throw StateError('Could not save orders');
    }
  }

  static Future<List<OrderModel>?> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyOrders);
    if (list != null && list.isNotEmpty) {
      try {
        return list
            .map((item) => OrderModel.fromMap(jsonDecode(item) as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveBatches(List<BatchModel> batches) async {
    final prefs = await SharedPreferences.getInstance();
    final list = batches.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(_keyBatches, list);
  }

  static Future<List<BatchModel>?> getBatches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyBatches);
    if (list != null && list.isNotEmpty) {
      try {
        return list
            .map((item) => BatchModel.fromMap(jsonDecode(item) as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveProducts(List<ProductModel> products) async {
    final prefs = await SharedPreferences.getInstance();
    final list = products.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList(_keyProducts, list);
  }

  static Future<List<ProductModel>?> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyProducts);
    if (list != null && list.isNotEmpty) {
      try {
        return list
            .map((item) => ProductModel.fromMap(jsonDecode(item) as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

