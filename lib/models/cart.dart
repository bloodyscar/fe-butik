class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String productImage;
  final int productStock;
  final String subtotal;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productImage,
    required this.productStock,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      cartId: json['cart_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productName: json['product_name'] ?? '',
      productDescription: json['product_description'] ?? '',
      productPrice: json['product_price'] ?? '0.00',
      productImage: json['product_image'] ?? '',
      productStock: json['product_stock'] ?? 0,
      subtotal: json['subtotal'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'product_name': productName,
      'product_description': productDescription,
      'product_price': productPrice,
      'product_image': productImage,
      'product_stock': productStock,
      'subtotal': subtotal,
    };
  }

  // Helper methods
  double get priceAsDouble => double.tryParse(productPrice) ?? 0.0;
  double get subtotalAsDouble => double.tryParse(subtotal) ?? 0.0;

  String get formattedPrice => 'Rp ${productPrice}';
  String get formattedSubtotal => 'Rp ${subtotal}';

  @override
  String toString() {
    return 'CartItem{id: $id, productName: $productName, quantity: $quantity, subtotal: $subtotal}';
  }
}

class Cart {
  final int id;
  final int userId;
  final DateTime createdAt;
  final String userName;
  final String userEmail;
  final List<CartItem> items;
  final int totalItems;
  final double totalAmount;

  Cart({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.totalItems,
    required this.totalAmount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<CartItem> items = itemsList
        .map((item) => CartItem.fromJson(item))
        .toList();

    return Cart(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      items: items,
      totalItems: json['total_items'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'user_email': userEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'total_items': totalItems,
      'total_amount': totalAmount,
    };
  }

  // Helper methods
  String get formattedTotalAmount => 'Rp ${totalAmount.toStringAsFixed(2)}';
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'Cart{id: $id, userName: $userName, totalItems: $totalItems, totalAmount: $totalAmount}';
  }
}

class CartResponse {
  final bool success;
  final List<Cart> carts;
  final int totalCarts;
  final String? message;

  CartResponse({
    required this.success,
    required this.carts,
    required this.totalCarts,
    this.message,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'] ?? {};
    var cartsList = data['carts'] as List? ?? [];
    List<Cart> carts = cartsList.map((cart) => Cart.fromJson(cart)).toList();

    return CartResponse(
      success: json['success'] ?? false,
      carts: carts,
      totalCarts: data['total_carts'] ?? 0,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'carts': carts.map((cart) => cart.toJson()).toList(),
        'total_carts': totalCarts,
      },
      'message': message,
    };
  }

  @override
  String toString() {
    return 'CartResponse{success: $success, totalCarts: $totalCarts, carts: ${carts.length}}';
  }
}
