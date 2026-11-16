import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        bg = Colors.amber.shade50;
        text = Colors.amber.shade900;
        icon = Icons.hourglass_top;
        break;
      case OrderStatus.confirmed:
        bg = Colors.blue.shade50;
        text = Colors.blue.shade800;
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.packing:
        bg = Colors.purple.shade50;
        text = Colors.purple.shade800;
        icon = Icons.inventory_2_outlined;
        break;
      case OrderStatus.shipping:
        bg = Colors.cyan.shade50;
        text = Colors.cyan.shade900;
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        bg = Colors.green.shade50;
        text = Colors.green.shade800;
        icon = Icons.task_alt;
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.shade50;
        text = Colors.red.shade800;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: text.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
