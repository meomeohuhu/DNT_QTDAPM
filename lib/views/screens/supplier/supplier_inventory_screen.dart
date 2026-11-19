import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/order_model.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/role_selector_bar.dart';
import '../../widgets/status_badge.dart';

class SupplierInventoryScreen extends StatefulWidget {
  const SupplierInventoryScreen({super.key});

  @override
  State<SupplierInventoryScreen> createState() => _SupplierInventoryScreenState();
}

class _SupplierInventoryScreenState extends State<SupplierInventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = Provider.of<ProductProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho hàng & Phân phối (NCC)'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              text: 'Tồn kho nông sản (${prodProv.products.length})',
            ),
            Tab(
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              text: 'Điều phối xuất kho (${orderProv.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Role selector bar
          const RoleSelectorBar(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: INVENTORY MANAGEMENT
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: prodProv.products.length,
                  itemBuilder: (context, index) {
                    final p = prodProv.products[index];
                    final isLowStock = p.stockQuantity < 45;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isLowStock ? AppColors.warning : AppColors.border,
                          width: isLowStock ? 1.5 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p.imageUrl,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 55,
                                  height: 55,
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.eco, color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Lô: ${p.batchId} • ${p.farmName}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Tồn kho: ${p.stockQuantity} ${p.unit}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isLowStock ? AppColors.warning : AppColors.primary,
                                        ),
                                      ),
                                      if (isLowStock) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Sắp hết',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Quick Restock Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                                  tooltip: 'Giảm 10',
                                  onPressed: p.stockQuantity < 10 ? null : () => _saveAction(
                                    context, () => prodProv.adjustStock(p.id, -10), 'Đã xuất kho.',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                  tooltip: 'Nhập kho +20',
                                  onPressed: () => _saveAction(
                                    context, () => prodProv.adjustStock(p.id, 20), 'Đã nhập kho.',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // TAB 2: DISPATCH ORDERS
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orderProv.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProv.orders[index];
                    final nextState = order.status.nextState;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                ),
                                StatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Khách: ${order.userName} (${order.userPhone})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Đ/C: ${order.shippingAddress}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (order.deliveryNote.isNotEmpty)
                              Text(
                                'Ghi chú: ${order.deliveryNote}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              '${order.items.length} món • Tổng: ${CurrencyFormatter.format(order.finalAmount)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 16, color: AppColors.divider),
                            // State Machine Advancement Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Đối tác: ${order.deliveryPartner}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ),
                                if (nextState != null)
                                  ElevatedButton.icon(
                                    onPressed: () => _saveAction(
                                      context,
                                      () => orderProv.advanceOrderStatus(order.id, order.status),
                                      'Đơn ${order.id} chuyển sang: ${nextState.displayName}',
                                    ),
                                    icon: const Icon(Icons.arrow_forward, size: 14),
                                    label: Text(
                                      'Chuyển sang: ${nextState.displayName}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                else
                                  const Text(
                                    'Đơn đã hoàn tất',
                                    style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                            if (order.returnStatus case final status?)
                              Text('Đổi/trả: ${status.label} · ${order.returnReason ?? ''}'),
                            if (order.returnStatus == ReturnRequestStatus.pending)
                              Wrap(
                                children: [
                                  TextButton(
                                    onPressed: () => _saveAction(
                                      context, () => orderProv.resolveReturn(order.id, approve: false),
                                      'Đã từ chối yêu cầu.',
                                    ),
                                    child: const Text('Từ chối'),
                                  ),
                                  TextButton(
                                    onPressed: () => _saveAction(
                                      context, () => orderProv.resolveReturn(order.id, approve: true),
                                      'Đã chấp nhận yêu cầu.',
                                    ),
                                    child: const Text('Chấp nhận'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAction(
    BuildContext context,
    Future<bool> Function() action,
    String success,
  ) async {
    String message;
    try {
      message = await action() ? success : 'Dữ liệu đã thay đổi hoặc tồn kho không đủ.';
    } catch (_) {
      message = 'Chưa lưu được thay đổi.';
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

