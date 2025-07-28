import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart.dart';

class CartService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  /// Get all carts for a specific user
  ///
  /// [userId] - The ID of the user whose carts to retrieve
  ///
  /// Returns [CartResponse] containing the carts data
  static Future<CartResponse> getAllCarts({required int userId}) async {
    try {
      // Construct the URL with user_id parameter
      final url = Uri.parse('$baseUrl/cart?user_id=$userId');

      print('📡 Fetching carts from: $url');

      // Make the HTTP GET request
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your connection');
            },
          );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CartResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // No carts found for the user
        return CartResponse(
          success: false,
          carts: [],
          totalCarts: 0,
          message: 'No carts found for this user',
        );
      } else if (response.statusCode == 400) {
        // Bad request (e.g., invalid user_id)
        final errorData = json.decode(response.body);
        return CartResponse(
          success: false,
          carts: [],
          totalCarts: 0,
          message: errorData['message'] ?? 'Invalid request',
        );
      } else {
        // Other HTTP errors
        throw Exception(
          'Failed to load carts. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getAllCarts: $e');

      // Return error response for different types of exceptions
      if (e.toString().contains('timeout')) {
        return CartResponse(
          success: false,
          carts: [],
          totalCarts: 0,
          message: 'Connection timeout - please try again',
        );
      } else if (e.toString().contains('SocketException')) {
        return CartResponse(
          success: false,
          carts: [],
          totalCarts: 0,
          message: 'No internet connection - please check your network',
        );
      } else {
        return CartResponse(
          success: false,
          carts: [],
          totalCarts: 0,
          message: 'Error loading carts: ${e.toString()}',
        );
      }
    }
  }

  /// Add item to cart
  ///
  /// [userId] - The ID of the user
  /// [productId] - The ID of the product to add
  /// [quantity] - The quantity to add (default: 1)
  ///
  /// Returns [Map<String, dynamic>] containing the response
  static Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/create');

      final body = {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      };

      print('📡 Adding to cart: $body');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your connection');
            },
          );

      print(
        '📡 Add to cart response: ${response.statusCode} - ${response.body}',
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Item added to cart successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add item to cart',
        };
      }
    } catch (e) {
      print('❌ Error in addToCart: $e');
      return {
        'success': false,
        'message': 'Error adding to cart: ${e.toString()}',
      };
    }
  }

  /// Update cart item quantity
  ///
  /// [cartItemId] - The ID of the cart item to update
  /// [quantity] - The new quantity
  ///
  /// Returns [Map<String, dynamic>] containing the response
  static Future<Map<String, dynamic>> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/$cartItemId');

      final body = {'quantity': quantity};

      print('📡 Updating cart item $cartItemId: $body');

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your connection');
            },
          );

      print(
        '📡 Update cart item response: ${response.statusCode} - ${response.body}',
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Cart item updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update cart item',
        };
      }
    } catch (e) {
      print('❌ Error in updateCartItem: $e');
      return {
        'success': false,
        'message': 'Error updating cart item: ${e.toString()}',
      };
    }
  }

  /// Remove item from cart
  ///
  /// [cartItemId] - The ID of the cart item to remove
  ///
  /// Returns [Map<String, dynamic>] containing the response
  static Future<Map<String, dynamic>> removeFromCart({
    required int cartItemId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/$cartItemId?type=item');

      print('📡 Removing cart item: $cartItemId');

      final response = await http
          .delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your connection');
            },
          );

      print(
        '📡 Remove cart item response: ${response.statusCode} - ${response.body}',
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Item removed from cart successfully',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to remove item from cart',
        };
      }
    } catch (e) {
      print('❌ Error in removeFromCart: $e');
      return {
        'success': false,
        'message': 'Error removing from cart: ${e.toString()}',
      };
    }
  }

  /// Clear all items from cart
  ///
  /// [cartId] - The ID of the cart to clear
  ///
  /// Returns [Map<String, dynamic>] containing the response
  static Future<Map<String, dynamic>> clearCart({required int cartId}) async {
    try {
      final url = Uri.parse('$baseUrl/cart/$cartId/clear');

      print('📡 Clearing cart: $cartId');

      final response = await http
          .delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your connection');
            },
          );

      print(
        '📡 Clear cart response: ${response.statusCode} - ${response.body}',
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Cart cleared successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to clear cart',
        };
      }
    } catch (e) {
      print('❌ Error in clearCart: $e');
      return {
        'success': false,
        'message': 'Error clearing cart: ${e.toString()}',
      };
    }
  }
}
