import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../service/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<Cart> _carts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalCarts = 0;

  // Current user ID (should be set when user logs in)
  int? _currentUserId;

  // Getters
  List<Cart> get carts => _carts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCarts => _totalCarts;
  int? get currentUserId => _currentUserId;

  // Get all cart items across all carts
  List<CartItem> get allCartItems {
    List<CartItem> allItems = [];
    for (Cart cart in _carts) {
      allItems.addAll(cart.items);
    }
    return allItems;
  }

  // Get total items count across all carts
  int get totalItemsCount {
    return _carts.fold(0, (sum, cart) => sum + cart.totalItems);
  }

  // Get total amount across all carts
  double get totalAmount {
    return _carts.fold(0.0, (sum, cart) => sum + cart.totalAmount);
  }

  // Get formatted total amount
  String get formattedTotalAmount => 'Rp ${totalAmount.toStringAsFixed(2)}';

  // Check if cart is empty
  bool get isEmpty => _carts.isEmpty || allCartItems.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // Set current user ID
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Load carts for current user
  Future<void> loadCarts() async {
    if (_currentUserId == null) {
      _errorMessage = 'User ID not set';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await CartService.getAllCarts(userId: _currentUserId!);

      if (response.success) {
        _carts = response.carts;
        _totalCarts = response.totalCarts;
        _errorMessage = null;
      } else {
        _carts = [];
        _totalCarts = 0;
        _errorMessage = response.message ?? 'Failed to load carts';
      }
    } catch (e) {
      _carts = [];
      _totalCarts = 0;
      _errorMessage = 'Error loading carts: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add item to cart
  Future<bool> addToCart({required int productId, int quantity = 1}) async {
    if (_currentUserId == null) {
      _errorMessage = 'User ID not set';
      notifyListeners();
      return false;
    }

    try {
      final response = await CartService.addToCart(
        userId: _currentUserId!,
        productId: productId,
        quantity: quantity,
      );

      if (response['success']) {
        // Reload carts to reflect the changes
        await loadCarts();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding to cart: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update cart item quantity
  Future<bool> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await CartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      if (response['success']) {
        // Reload carts to reflect the changes
        await loadCarts();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating cart item: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart({required int cartItemId}) async {
    try {
      final response = await CartService.removeFromCart(cartItemId: cartItemId);

      if (response['success']) {
        // Reload carts to reflect the changes
        await loadCarts();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error removing from cart: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart({required int cartId}) async {
    try {
      final response = await CartService.clearCart(cartId: cartId);

      if (response['success']) {
        // Reload carts to reflect the changes
        await loadCarts();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error clearing cart: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get cart item by product ID
  CartItem? getCartItemByProductId(int productId) {
    for (Cart cart in _carts) {
      for (CartItem item in cart.items) {
        if (item.productId == productId) {
          return item;
        }
      }
    }
    return null;
  }

  // Check if product is in cart
  bool isProductInCart(int productId) {
    return getCartItemByProductId(productId) != null;
  }

  // Get quantity of product in cart
  int getProductQuantityInCart(int productId) {
    final cartItem = getCartItemByProductId(productId);
    return cartItem?.quantity ?? 0;
  }

  // Refresh carts (pull to refresh)
  Future<void> refreshCarts() async {
    await loadCarts();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all cart items using removeFromCart
  Future<bool> clearAllCartItems() async {
    try {
      final cartItems = allCartItems;

      if (cartItems.isEmpty) {
        return true; // Nothing to clear
      }

      // Remove each cart item individually
      for (CartItem item in cartItems) {
        final success = await removeFromCart(cartItemId: item.id);
        if (!success) {
          _errorMessage = 'Failed to remove some items from cart';
          return false;
        }
      }

      // Reload carts to reflect changes
      await loadCarts();
      return true;
    } catch (e) {
      _errorMessage = 'Error clearing all cart items: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear all data (on logout)
  void clearData() {
    _carts = [];
    _totalCarts = 0;
    _errorMessage = null;
    _currentUserId = null;
    _isLoading = false;
    notifyListeners();
  }
}
