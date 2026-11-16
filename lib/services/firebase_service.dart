import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/batch_model.dart';
import '../firebase_options.dart';
import 'mock_data_service.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      if (kDebugMode) {
        print('Firebase successfully initialized for project: dnt-q-90cae');
      }
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        print('Firebase running in local offline mode: $e');
      }
    }
  }

  // --- Firestore Integration with Safe Fallback ---

  static Future<List<ProductModel>?> getProductsFromFirestore() async {
    if (!_isInitialized) return null;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
    } catch (e) {
      if (kDebugMode) print('Firestore read products error: $e');
      return null;
    }
  }

  static Future<void> syncOrderToFirestore(OrderModel order) async {
    if (!_isInitialized) return;
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .set(order.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Firestore write order error: $e');
    }
  }

  static Future<void> syncBatchToFirestore(BatchModel batch) async {
    if (!_isInitialized) return;
    try {
      await FirebaseFirestore.instance
          .collection('batches')
          .doc(batch.id)
          .set(batch.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Firestore write batch error: $e');
    }
  }

  static Future<BatchModel?> getBatchByCode(String code) async {
    if (!_isInitialized) return null;
    try {
      final doc = await FirebaseFirestore.instance.collection('batches').doc(code).get();
      if (doc.exists && doc.data() != null) {
        return BatchModel.fromMap(doc.data()!);
      }
    } catch (e) {
      if (kDebugMode) print('Firestore fetch batch error: $e');
    }
    return null;
  }

  /// Pushes all agricultural products, traceability batches, farms, and orders into Cloud Firestore
  static Future<bool> seedAllDataToFirestore() async {
    if (!_isInitialized) return false;
    try {
      final firestore = FirebaseFirestore.instance;

      for (final p in MockDataService.getMockProducts()) {
        await firestore.collection('products').doc(p.id).set(p.toMap(), SetOptions(merge: true));
      }
      for (final b in MockDataService.getMockBatches()) {
        await firestore.collection('batches').doc(b.id).set(b.toMap(), SetOptions(merge: true));
      }
      for (final f in MockDataService.getMockFarms()) {
        await firestore.collection('farms').doc(f.id).set(f.toMap(), SetOptions(merge: true));
      }
      for (final o in MockDataService.getMockOrders()) {
        await firestore.collection('orders').doc(o.id).set(o.toMap(), SetOptions(merge: true));
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Error seeding data to Firestore: $e');
      return false;
    }
  }

  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (!_isInitialized) return null;
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) print('Firebase Auth sign in error: $e');
      rethrow;
    }
  }
}
