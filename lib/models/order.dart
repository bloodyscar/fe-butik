import '../utils/price_formatter.dart';

class OrderItem {
  final int? id;
  final int? orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final String? productName;
  final String? productDescription;
  final String? productImage;

  OrderItem({
    this.id,
    this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.productName,
    this.productDescription,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _parseToInt(json['id']),
      orderId: _parseToInt(json['order_id']),
      productId: _parseToInt(json['product_id']) ?? 0,
      quantity: _parseToInt(json['quantity']) ?? 0,
      unitPrice: _parseToDouble(json['unit_price']) ?? 0.0,
      productName: json['product_name']?.toString(),
      productDescription: json['product_description']?.toString(),
      productImage: json['product_image']?.toString(),
    );
  }

  // Helper method to safely parse integers
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // Helper method to safely parse doubles
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  // Helper methods
  double get subtotal => unitPrice * quantity;
  String get formattedUnitPrice => PriceFormatter.formatPrice(unitPrice);
  String get formattedSubtotal => PriceFormatter.formatPrice(subtotal);

  @override
  String toString() {
    return 'OrderItem{productId: $productId, quantity: $quantity, unitPrice: $unitPrice}';
  }
}

class Order {
  final int? id;
  final int userId;
  final double totalPrice;
  final String shippingMethod;
  final String shippingAddress;
  final double shippingCost;
  final String? transferProof;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;
  final int itemsCount;

  Order({
    this.id,
    required this.userId,
    required this.totalPrice,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.shippingCost,
    this.transferProof,
    this.status = 'proses',
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    required this.itemsCount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItem> items = itemsList
        .map((item) => OrderItem.fromJson(item))
        .toList();

    return Order(
      id: OrderItem._parseToInt(json['id'] ?? json['orderId']),
      userId: OrderItem._parseToInt(json['user_id']) ?? 0,
      totalPrice: OrderItem._parseToDouble(json['total_price']) ?? 0.0,
      shippingMethod: json['shipping_method']?.toString() ?? '',
      shippingAddress: json['shipping_address']?.toString() ?? '',
      shippingCost: OrderItem._parseToDouble(json['shipping_cost']) ?? 0.0,
      transferProof: json['transfer_proof']?.toString(),
      status: json['status']?.toString() ?? 'proses',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items: items,
      itemsCount: OrderItem._parseToInt(json['items_count']) ?? items.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'shipping_method': shippingMethod,
      'shipping_address': shippingAddress,
      'shipping_cost': shippingCost,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods
  double get subtotalPrice => totalPrice - shippingCost;
  String get formattedTotalPrice => PriceFormatter.formatPrice(totalPrice);
  String get formattedShippingCost => PriceFormatter.formatPrice(shippingCost);
  String get formattedSubtotalPrice => PriceFormatter.formatPrice(subtotalPrice);

  @override
  String toString() {
    return 'Order{id: $id, userId: $userId, totalPrice: $totalPrice, status: $status}';
  }
}

class CreateOrderRequest {
  final int userId;
  final String shippingMethod;
  final String shippingAddress;
  final double shippingCost;
  final List<OrderItem> items;
  final String? transferProofPath;

  CreateOrderRequest({
    required this.userId,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.shippingCost,
    required this.items,
    this.transferProofPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'shipping_method': shippingMethod,
      'shipping_address': shippingAddress,
      'shipping_cost': shippingCost,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CreateOrderRequest{userId: $userId, shippingMethod: $shippingMethod, itemsCount: ${items.length}}';
  }
}

class OrderResponse {
  final bool success;
  final String? message;
  final Order? order;
  final String? error;

  OrderResponse({required this.success, this.message, this.order, this.error});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['success'] ?? false,
      message: json['message'],
      order: json['data'] != null ? Order.fromJson(json['data']) : null,
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'OrderResponse{success: $success, message: $message, error: $error}';
  }
}
