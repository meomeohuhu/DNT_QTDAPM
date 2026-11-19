import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/models/order_model.dart';
import 'package:freshfarm/providers/order_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('checkout preserves the QR reference and delivery details', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = OrderProvider();
    await provider.loadCompletion;
    final orderId = provider.newOrderId();

    await provider.createOrder(
      orderId: orderId,
      userId: 'test-customer',
      userName: 'Khách demo',
      userPhone: '0900000000',
      shippingAddress: 'Đà Nẵng',
      deliveryPartner: 'Viettel Post Nông Sản',
      deliveryNote: 'Gọi trước khi giao',
      items: [
        OrderItemModel(
          productId: 'test-product',
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
    );

    final reloaded = OrderProvider();
    await reloaded.loadCompletion;
    final order = reloaded.getOrdersForUser('test-customer').single;
    expect(order.id, orderId);
    expect(order.deliveryPartner, 'Viettel Post Nông Sản');
    expect(order.deliveryNote, 'Gọi trước khi giao');
    expect(order.isPaid, isFalse);
  });
}
