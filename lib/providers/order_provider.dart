import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../service/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  Order? _currentOrder;
  bool _isCreatingOrder = false;

  // Current user ID (should be set when user logs in)
  int? _currentUserId;

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  String? get errorMessage => _errorMessage;
  Order? get currentOrder => _currentOrder;
  int? get currentUserId => _currentUserId;

  // Filter orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get order counts by status
  Map<String, int> get orderCounts {
    Map<String, int> counts = {};
    for (Order order in _orders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    return counts;
  }

  // Set current user ID
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Create a new order
  Future<bool> createOrder({required CreateOrderRequest orderRequest}) async {
    _isCreatingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate order request
      final validationError = OrderService.validateOrderRequest(orderRequest);
      if (validationError != null) {
        _errorMessage = validationError;
        _isCreatingOrder = false;
        notifyListeners();
        return false;
      }

      print('📦 Creating order: ${orderRequest.toString()}');

      final response = await OrderService.createOrder(request: orderRequest);

      if (response.success && response.order != null) {
        _currentOrder = response.order;
        // Add the new order to the beginning of the list
        _orders.insert(0, response.order!);
        _errorMessage = null;
        _isCreatingOrder = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Failed to create order';
        _isCreatingOrder = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating order: ${e.toString()}';
      _isCreatingOrder = false;
      notifyListeners();
      return false;
    }
  }

  // Load user orders
  Future<void> loadUserOrders({
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    if (_currentUserId == null) {
      _errorMessage = 'User ID not set';
      notifyListeners();
      return;
    }

    if (refresh) {
      _orders.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await OrderService.getUserOrders(
        userId: _currentUserId!,
        page: page,
        limit: limit,
      );

      if (response['success']) {
        final ordersData = response['data']['orders'] as List? ?? [];
        List<Order> newOrders = ordersData
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();

        if (refresh || page == 1) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        _errorMessage = null;
      } else {
        if (refresh || _orders.isEmpty) {
          _orders = [];
        }
        _errorMessage = response['error'] ?? response['message'];
      }
    } catch (e) {
      if (refresh || _orders.isEmpty) {
        _orders = [];
      }
      _errorMessage = 'Error loading orders: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get order details by ID
  Future<Order?> getOrderDetails(int orderId) async {
    try {
      final response = await OrderService.getOrderById(orderId: orderId);

      if (response['success']) {
        final order = Order.fromJson(response['data']);

        // Update the order in the list if it exists
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = order;
          notifyListeners();
        }

        return order;
      } else {
        _errorMessage = response['error'] ?? response['message'];
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error loading order details: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Update order status (admin function)
  Future<bool> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final response = await OrderService.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      if (response['success']) {
        // Update the order in the list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = Order(
            id: _orders[index].id,
            userId: _orders[index].userId,
            totalPrice: _orders[index].totalPrice,
            shippingMethod: _orders[index].shippingMethod,
            shippingAddress: _orders[index].shippingAddress,
            shippingCost: _orders[index].shippingCost,
            transferProof: _orders[index].transferProof,
            status: status,
            createdAt: _orders[index].createdAt,
            updatedAt: DateTime.now(),
            items: _orders[index].items,
            itemsCount: _orders[index].itemsCount,
          );
          notifyListeners();
        }

        _errorMessage = null;
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating order status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Cancel an order
  Future<bool> cancelOrder({required int orderId, String? reason}) async {
    try {
      final response = await OrderService.cancelOrder(
        orderId: orderId,
        reason: reason,
      );

      if (response['success']) {
        // Update the order status to cancelled
        await updateOrderStatus(orderId: orderId, status: 'cancelled');
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error cancelling order: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Create order from cart
  Future<bool> createOrderFromCart({
    required List<dynamic> cartItems,
    required String shippingMethod,
    required String shippingAddress,
    required double shippingCost,
    File? transferProofFile,
  }) async {
    if (_currentUserId == null) {
      _errorMessage = 'User ID not set';
      notifyListeners();
      return false;
    }

    final orderRequest = OrderService.createOrderFromCart(
      userId: _currentUserId!,
      cartItems: cartItems,
      shippingMethod: shippingMethod,
      shippingAddress: shippingAddress,
      shippingCost: shippingCost,
    );

    return await createOrder(orderRequest: orderRequest);
  }

  // Get order by ID from local list
  Order? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Refresh orders (pull to refresh)
  Future<void> refreshOrders() async {
    await loadUserOrders(refresh: true);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data (on logout)
  void clearData() {
    _orders = [];
    _errorMessage = null;
    _currentOrder = null;
    _currentUserId = null;
    _isLoading = false;
    _isCreatingOrder = false;
    notifyListeners();
  }

  // Filter orders by date range
  List<Order> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return _orders.where((order) {
      if (order.createdAt == null) return false;
      return order.createdAt!.isAfter(startDate) &&
          order.createdAt!.isBefore(endDate);
    }).toList();
  }

  // Get total spent by user
  double get totalSpent {
    return _orders.fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  // Get formatted total spent
  String get formattedTotalSpent => 'Rp ${totalSpent.toStringAsFixed(2)}';

  // Check if user has any orders
  bool get hasOrders => _orders.isNotEmpty;
}
