import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/models/order_model.dart';
import 'package:freshfarm/providers/order_provider.dart';
import 'package:freshfarm/providers/product_provider.dart';
import 'package:freshfarm/services/mock_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<OrderModel> createOrder(
    OrderProvider provider,
    String orderId,
    String productId,
    int Function(String) availableStock,
  ) {
    return provider.createOrder(
      orderId: orderId,
      userId: 'test-customer',
      userName: 'Khách demo',
      userPhone: '0900000000',
      shippingAddress: 'Đà Nẵng',
      deliveryPartner: 'Viettel Post Nông Sản',
      deliveryNote: 'Gọi trước khi giao',
      items: [
        OrderItemModel(
          productId: productId,
          productName: 'Cà chua',
          imageUrl: '',
          price: 50000,
          quantity: 1,
          unit: 'kg',
        ),
      ],
      totalAmount: 50000,
      shippingFee: 25000,
      discountAmount: 0,
      finalAmount: 75000,
      paymentMethod: PaymentMethod.vietqr,
      availableStock: availableStock,
    );
  }

  test('checkout preserves the QR reference and delivery details', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = OrderProvider();
    await provider.loadCompletion;
    final orderId = provider.newOrderId();

    await createOrder(provider, orderId, 'test-product', (_) => 1);

    final reloaded = OrderProvider();
    await reloaded.loadCompletion;
    final order = reloaded.getOrdersForUser('test-customer').single;
    expect(order.id, orderId);
    expect(order.deliveryPartner, 'Viettel Post Nông Sản');
    expect(order.deliveryNote, 'Gọi trước khi giao');
    expect(order.isPaid, isFalse);
  });

  test(
    'concurrent checkout, retry and cancellation keep stock consistent',
    () async {
      SharedPreferences.setMockInitialValues({});
      final orders = OrderProvider();
      final products = ProductProvider(orders);
      await products.loadCompletion;
      final id = MockDataService.getMockProducts().first.id;
      int available(String id) => products.getProductById(id)!.stockQuantity;
      expect(await products.adjustStock(id, 1 - available(id)), isTrue);

      final orderId = orders.newOrderId();
      final first = createOrder(orders, orderId, id, available);
      final second = createOrder(orders, orders.newOrderId(), id, available);
      final rejected = expectLater(second, throwsStateError);
      await first;
      await rejected;
      await createOrder(orders, orderId, id, available);
      expect(available(id), 0);

      final reopened = OrderProvider();
      final reopenedProducts = ProductProvider(reopened);
      await reopened.loadCompletion;
      await reopenedProducts.loadCompletion;
      expect(reopenedProducts.getProductById(id)!.stockQuantity, 0);
      expect(await reopened.cancelOrder(orderId, 'another-user'), isFalse);
      expect(await reopened.cancelOrder(orderId, 'test-customer'), isTrue);
      expect(await reopened.cancelOrder(orderId, 'test-customer'), isFalse);
      expect(reopenedProducts.getProductById(id)!.stockQuantity, 1);
    },
  );

  test('the warehouse can resolve a delivered order return once', () async {
    SharedPreferences.setMockInitialValues({});
    final orders = OrderProvider();
    final id = orders.newOrderId();
    await createOrder(orders, id, 'test-product', (_) => 1);
    expect(
      await orders.requestReturn(id, 'test-customer', 'Hàng hỏng'),
      isFalse,
    );
    for (final status in [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.packing,
      OrderStatus.shipping,
    ]) {
      expect(await orders.advanceOrderStatus(id, status), isTrue);
    }
    expect(await orders.cancelOrder(id, 'test-customer'), isFalse);
    expect(
      await orders.requestReturn(id, 'test-customer', 'Hàng hỏng'),
      isTrue,
    );
    expect(await orders.resolveReturn(id, approve: true), isTrue);
    expect(await orders.resolveReturn(id, approve: false), isFalse);

    final reloaded = OrderProvider();
    await reloaded.loadCompletion;
    final order = reloaded.getOrdersForUser('test-customer').single;
    expect(order.returnReason, 'Hàng hỏng');
    expect(order.returnStatus, ReturnRequestStatus.approved);
    expect(reloaded.reservedQuantity('test-product'), 1);
  });
}
