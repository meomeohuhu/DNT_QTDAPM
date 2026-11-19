import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/models/user_model.dart';
import 'package:freshfarm/providers/auth_provider.dart';
import 'package:freshfarm/providers/cart_provider.dart';
import 'package:freshfarm/services/mock_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('voucher applies only while the order is eligible', () {
    final cart = CartProvider();
    final product = MockDataService.getMockProducts().first;
    final quantity = (CartProvider.voucherMinimum / product.price).ceil();
    cart.addToCart(product, quantity: quantity);
    final originalTotal = cart.totalAmount;

    cart.toggleVoucher();
    expect(cart.totalAmount, originalTotal - CartProvider.voucherDiscount);

    cart.updateQuantity(product.id, quantity - 1);
    expect(cart.hasVoucher, isFalse);
    cart.updateQuantity(product.id, quantity);
    expect(cart.hasVoucher, isFalse);
  });

  test('delivery profile is restored for the same demo role', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.switchRole(UserRole.customer);

    await auth.updateProfile(
      name: 'Khách demo',
      phone: '0900000123',
      address: 'Đà Nẵng',
    );
    await auth.switchRole(UserRole.supplier);
    expect(auth.currentUser!.name, isNot('Khách demo'));

    final reopened = AuthProvider();
    await reopened.switchRole(UserRole.customer);
    expect(reopened.currentUser!.name, 'Khách demo');
    expect(reopened.currentUser!.phone, '0900000123');
    expect(reopened.currentUser!.address, 'Đà Nẵng');
  });
}
