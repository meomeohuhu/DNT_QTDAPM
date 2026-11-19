import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/order_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/vietqr_dialog.dart';
import 'order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;

  bool _placingOrder = false;
  PaymentMethod _selectedPayment = PaymentMethod.vietqr;
  String _selectedLogistics = 'AhaMove Xe Lạnh Chuẩn 18°C';

  final List<String> _logisticsOptions = [
    'AhaMove Xe Lạnh Chuẩn 18°C',
    'Giao Hàng Nhanh (FastCold)',
    'Viettel Post Nông Sản',
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    _nameController = TextEditingController(text: user?.name ?? 'Trần Dương Thái');
    _phoneController = TextEditingController(text: user?.phone ?? '0905123456');
    _addressController = TextEditingController(
      text: user?.address ?? '470 Đường Trần Đại Nghĩa, Q. Ngũ Hành Sơn, TP. Đà Nẵng',
    );
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder(String orderId, {required bool isPrepaid}) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prodProv = Provider.of<ProductProvider>(context, listen: false);

    await orderProv.loadCompletion;
    await prodProv.loadCompletion;
    if (!mounted || !_canPlaceOrder()) return;

    final orderItems = cart.items.map((item) {
      return OrderItemModel(
        productId: item.product.id,
        productName: item.product.name,
        imageUrl: item.product.imageUrl,
        price: item.product.price,
        quantity: item.quantity,
        unit: item.product.unit,
      );
    }).toList();

    final order = await orderProv.createOrder(
      orderId: orderId,
      userId: auth.currentUser?.id ?? 'USR-001',
      userName: _nameController.text.trim(),
      userPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      deliveryPartner: _selectedLogistics,
      deliveryNote: _noteController.text.trim(),
      items: orderItems,
      totalAmount: cart.subtotal,
      shippingFee: cart.shippingFee,
      discountAmount: cart.discountAmount,
      finalAmount: cart.totalAmount,
      paymentMethod: _selectedPayment,
      isPaid: isPrepaid,
      availableStock: (id) => prodProv.getProductById(id)?.stockQuantity ?? 0,
    );

    cart.clearCart();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thành công! Mã đơn: ${order.id}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
      );
    }
  }

  bool _canPlaceOrder() {
    if (!_formKey.currentState!.validate()) return false;
    final cart = context.read<CartProvider>();
    final products = context.read<ProductProvider>();
    if (cart.items.isEmpty) return false;

    for (final item in cart.items) {
      final available = products.getProductById(item.product.id)?.stockQuantity ?? 0;
      if (item.quantity > available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.product.name} chỉ còn $available trong kho.')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _handlePlaceOrder() async {
    if (_placingOrder || !_canPlaceOrder()) return;
    final cart = context.read<CartProvider>();
    final orderId = context.read<OrderProvider>().newOrderId();
    final isPrepaid = _selectedPayment == PaymentMethod.vietqr;
    setState(() => _placingOrder = true);

    try {
      if (isPrepaid) {
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => VietQRDialog(
            orderId: orderId,
            amount: cart.totalAmount,
          ),
        );
        if (!mounted || confirmed != true) return;
      }

      await _submitOrder(orderId, isPrepaid: isPrepaid);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is StateError
              ? error.message.toString()
              : 'Chưa lưu được đơn hàng. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đặt hàng & Thanh toán'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address Card
                _buildCardHeader(Icons.location_on_outlined, 'Thông tin người nhận & Địa chỉ giao hàng'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên người nhận'),
                  validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Số điện thoại liên lạc'),
                  validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Địa chỉ nhận hàng chi tiết'),
                  validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                ),
                const SizedBox(height: 20),

                // Logistics Partner Selection
                _buildCardHeader(Icons.local_shipping_outlined, 'Đơn vị vận chuyển chuyên dụng'),
                const SizedBox(height: 10),
                ..._logisticsOptions.map((opt) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(opt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Bảo quản thùng xốp giữ nhiệt lạnh 18°C - 22°C', style: TextStyle(fontSize: 11)),
                    value: opt,
                    groupValue: _selectedLogistics,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _selectedLogistics = val!),
                  );
                }),
                const SizedBox(height: 16),

                // Payment Method Selection
                _buildCardHeader(Icons.payments_outlined, 'Phương thức thanh toán'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<PaymentMethod>(
                        value: PaymentMethod.vietqr,
                        groupValue: _selectedPayment,
                        activeColor: AppColors.primary,
                        title: const Row(
                          children: [
                            Icon(Icons.qr_code_2, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Chuyển khoản VietQR Napas 247 (Khuyên dùng)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Tự động sinh mã QR chuyển khoản, xác nhận tức thì qua ngân hàng',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        onChanged: (val) => setState(() => _selectedPayment = val!),
                      ),
                      const Divider(height: 1, color: AppColors.divider),
                      RadioListTile<PaymentMethod>(
                        value: PaymentMethod.cod,
                        groupValue: _selectedPayment,
                        activeColor: AppColors.primary,
                        title: const Row(
                          children: [
                            Icon(Icons.money, color: AppColors.accent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Thanh toán khi nhận hàng (COD)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Kiểm tra hàng tươi ngon chuẩn VietGAP trước khi thanh toán cho shipper',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        onChanged: (val) => setState(() => _selectedPayment = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Order Summary Card
                _buildCardHeader(Icons.receipt_long_outlined, 'Tóm tắt đơn hàng (${cart.itemCount} sản phẩm)'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      ...cart.items.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${it.product.name} (x${it.quantity})',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(it.totalPrice),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 16, color: AppColors.divider),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền hàng:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(CurrencyFormatter.format(cart.subtotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Phí giao hàng lạnh:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            cart.shippingFee == 0 ? 'Miễn phí' : CurrencyFormatter.format(cart.shippingFee),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cart.shippingFee == 0 ? AppColors.primary : AppColors.textPrimary),
                          ),
                        ],
                      ),
                      if (cart.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giảm giá ưu đãi:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('-${CurrencyFormatter.format(cart.discountAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent)),
                          ],
                        ),
                      ],
                      const Divider(height: 16, color: AppColors.divider),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TỔNG THANH TOÁN:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            CurrencyFormatter.format(cart.totalAmount),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _placingOrder ? null : _handlePlaceOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _selectedPayment == PaymentMethod.vietqr
                          ? 'Mở mã VietQR chuyển khoản (${CurrencyFormatter.format(cart.totalAmount)})'
                          : 'Đặt hàng ngay (COD - ${CurrencyFormatter.format(cart.totalAmount)})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

