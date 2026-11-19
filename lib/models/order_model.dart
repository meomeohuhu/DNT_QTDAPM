enum ReturnRequestStatus {
  pending('Chờ kho xử lý'),
  approved('Đã chấp nhận'),
  rejected('Đã từ chối');

  const ReturnRequestStatus(this.label);
  final String label;
}

enum OrderStatus {
  pending, // Chờ duyệt
  confirmed, // Đã xác nhận
  packing, // Đang đóng gói
  shipping, // Đang giao
  delivered, // Đã giao thành công
  cancelled, // Đã hủy
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã duyệt đơn';
      case OrderStatus.packing:
        return 'Đang đóng gói';
      case OrderStatus.shipping:
        return 'Đang vận chuyển';
      case OrderStatus.delivered:
        return 'Đã giao thành công';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  OrderStatus? get nextState {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.packing;
      case OrderStatus.packing:
        return OrderStatus.shipping;
      case OrderStatus.shipping:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }
}

enum PaymentMethod {
  cod,
  vietqr,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cod:
        return 'Thanh toán khi nhận hàng (COD)';
      case PaymentMethod.vietqr:
        return 'Chuyển khoản VietQR Napas 247';
    }
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String unit;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unit: map['unit'] ?? 'kg',
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String shippingAddress;
  final String deliveryNote;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double shippingFee;
  final double discountAmount;
  final double finalAmount;
  final PaymentMethod paymentMethod;
  final bool reservesStock;
  String? returnReason;
  ReturnRequestStatus? returnStatus;
  bool isPaid;
  OrderStatus status;
  final DateTime createdAt;
  final String deliveryTrackingCode;
  final String deliveryPartner;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.shippingAddress,
    this.deliveryNote = '',
    required this.items,
    required this.totalAmount,
    required this.shippingFee,
    this.discountAmount = 0.0,
    required this.finalAmount,
    required this.paymentMethod,
    this.isPaid = false,
    this.reservesStock = false,
    this.returnReason,
    this.returnStatus,
    this.status = OrderStatus.pending,
    required this.createdAt,
    required this.deliveryTrackingCode,
    required this.deliveryPartner,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'shippingAddress': shippingAddress,
      'deliveryNote': deliveryNote,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingFee': shippingFee,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod.name,
      'isPaid': isPaid,
      'reservesStock': reservesStock,
      'returnReason': returnReason,
      'returnStatus': returnStatus?.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'deliveryTrackingCode': deliveryTrackingCode,
      'deliveryPartner': deliveryPartner,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      shippingAddress: map['shippingAddress'] ?? '',
      deliveryNote: map['deliveryNote'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (map['shippingFee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (map['finalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cod,
      ),
      isPaid: map['isPaid'] ?? false,
      reservesStock: map['reservesStock'] == true,
      returnReason: map['returnReason'],
      returnStatus: ReturnRequestStatus.values.asNameMap()[map['returnStatus']],
      status: OrderStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      deliveryTrackingCode: map['deliveryTrackingCode'] ?? '',
      deliveryPartner: map['deliveryPartner'] ?? 'AhaMove Xe Lạnh',
    );
  }
}

