import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../services/mock_data_service.dart';
import '../services/storage_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  Future<void> _operation = Future.value();

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  late final Future<void> loadCompletion;

  OrderProvider() {
    loadCompletion = loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    final cached = await StorageService.getOrders();
    if (cached != null && cached.isNotEmpty) {
      _orders = cached;
    } else {
      _orders = MockDataService.getMockOrders();
      await StorageService.saveOrders(_orders);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<OrderModel> getOrdersByStatus(OrderStatus? status) {
    if (status == null) return _orders;
    return _orders.where((o) => o.status == status).toList();
  }

  List<OrderModel> getOrdersForUser(String userId) {
    return _orders.where((o) => o.userId == userId).toList();
  }

  Future<T> runInventoryOperation<T>(Future<T> Function() action) {
    final next = _operation.then((_) async {
      await loadCompletion;
      return action();
    });
    _operation = next.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return next;
  }

  int reservedQuantity(String productId) {
    return _orders
        .where((order) => order.reservesStock && order.status != OrderStatus.cancelled)
        .expand((order) => order.items)
        .where((item) => item.productId == productId)
        .fold(0, (total, item) => total + item.quantity);
  }

  String newOrderId() {
    final now = DateTime.now();
    final date = now.toIso8601String().substring(0, 10).replaceAll('-', '');
    final suffix = const Uuid().v4().substring(0, 8).toUpperCase();
    return 'FF-$date-$suffix';
  }

  Future<OrderModel> createOrder({
    required String orderId,
    required String userId,
    required String userName,
    required String userPhone,
    required String shippingAddress,
    required String deliveryPartner,
    String deliveryNote = '',
    required List<OrderItemModel> items,
    required double totalAmount,
    required double shippingFee,
    required double discountAmount,
    required double finalAmount,
    required PaymentMethod paymentMethod,
    bool isPaid = false,
    required int Function(String productId) availableStock,
  }) => runInventoryOperation(() async {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    if (items.isEmpty) throw StateError('Đơn hàng chưa có sản phẩm.');
    final quantities = <String, int>{};
    for (final item in items) {
      if (item.quantity <= 0) throw StateError('Số lượng sản phẩm không hợp lệ.');
      final quantity = (quantities[item.productId] ?? 0) + item.quantity;
      if (quantity > availableStock(item.productId)) {
        throw StateError('${item.productName} không đủ hàng trong kho.');
      }
      quantities[item.productId] = quantity;
    }
    final newOrder = OrderModel(
      id: orderId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      shippingAddress: shippingAddress,
      deliveryNote: deliveryNote,
      items: List.unmodifiable(items),
      reservesStock: true,
      totalAmount: totalAmount,
      shippingFee: shippingFee,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      paymentMethod: paymentMethod,
      isPaid: isPaid,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      deliveryTrackingCode: 'COLD-FF-${orderId.split('-').last}',
      deliveryPartner: deliveryPartner,
    );

    final updatedOrders = [newOrder, ..._orders];
    await StorageService.saveOrders(updatedOrders);
    _orders = updatedOrders;
    notifyListeners();
    return newOrder;
  });

  Future<bool> advanceOrderStatus(String orderId, OrderStatus expectedStatus) {
    return _updateOrder(orderId, (order) {
      if (order.status != expectedStatus) return false;
      final next = order.status.nextState;
      if (next == null) return false;
      order.status = next;
      if (next == OrderStatus.delivered) order.isPaid = true;
      return true;
    });
  }

  Future<bool> cancelOrder(String orderId, String userId) {
    return _updateOrder(orderId, (order) {
      if (order.userId != userId || order.status != OrderStatus.pending) {
        return false;
      }
      order.status = OrderStatus.cancelled;
      return true;
    });
  }

  Future<bool> requestReturn(String orderId, String userId, String reason) {
    return _updateOrder(orderId, (order) {
      if (order.userId != userId ||
          order.status != OrderStatus.delivered ||
          order.returnStatus != null ||
          reason.trim().isEmpty) {
        return false;
      }
      order.returnReason = reason.trim();
      order.returnStatus = ReturnRequestStatus.pending;
      return true;
    });
  }

  Future<bool> resolveReturn(String orderId, {required bool approve}) {
    return _updateOrder(orderId, (order) {
      if (order.returnStatus != ReturnRequestStatus.pending) return false;
      order.returnStatus = approve
          ? ReturnRequestStatus.approved
          : ReturnRequestStatus.rejected;
      return true;
    });
  }

  Future<bool> _updateOrder(String orderId, bool Function(OrderModel) update) {
    return runInventoryOperation(() async {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) return false;
      final order = OrderModel.fromMap(_orders[index].toMap());
      if (!update(order)) return false;
      final updated = [..._orders]..[index] = order;
      await StorageService.saveOrders(updated);
      _orders = updated;
      notifyListeners();
      return true;
    });
  }

  // Dashboard Aggregations for Admin
  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelled && o.isPaid)
      .fold(0.0, (sum, o) => sum + o.finalAmount);

  int get completedOrderCount => _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get pendingOrderCount => _orders.where((o) => o.status == OrderStatus.pending).length;
  int get shippingOrderCount => _orders.where((o) => o.status == OrderStatus.shipping).length;
}

