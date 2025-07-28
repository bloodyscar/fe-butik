import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  static const String baseUrl = 'http://10.0.2.2:3000/orders';

  /// Create a new order
  ///
  /// [request] - CreateOrderRequest containing order details
  /// [transferProofFile] - Optional file for transfer proof image
  ///
  /// Returns [OrderResponse] containing the created order details
  static Future<OrderResponse> createOrder({
    required CreateOrderRequest request,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/create');

      print('📡 Creating order: ${request.toString()}');

      // Create multipart request for file upload support
      var multipartRequest = http.MultipartRequest('POST', url);

      // Add headers
      multipartRequest.headers.addAll({'Accept': 'application/json'});

      // Add form fields
      multipartRequest.fields['user_id'] = request.userId.toString();
      multipartRequest.fields['shipping_method'] = request.shippingMethod;
      multipartRequest.fields['shipping_address'] = request.shippingAddress;
      multipartRequest.fields['shipping_cost'] = request.shippingCost
          .toString();

      // Convert items to JSON string as expected by the API
      multipartRequest.fields['items'] = json.encode(
        request.items.map((item) => item.toJson()).toList(),
      );
      print('📡 Sending order request to: $url');
      print('📋 Order fields: ${multipartRequest.fields}');

      // Send the request with timeout
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your connection');
        },
      );

      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return OrderResponse.fromJson(jsonData);
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          print('📡 Raw response: ${response.body}');
          return OrderResponse(
            success: false,
            error: 'Error parsing server response: $parseError',
          );
        }
      } else if (response.statusCode == 400) {
        // Bad request (validation errors)
        try {
          final errorData = json.decode(response.body);
          return OrderResponse(
            success: false,
            error: errorData['error'] ?? 'Invalid request data',
          );
        } catch (parseError) {
          return OrderResponse(
            success: false,
            error: 'Server returned error: ${response.body}',
          );
        }
      } else if (response.statusCode == 404) {
        return OrderResponse(success: false, error: 'Order endpoint not found');
      } else {
        // Other HTTP errors
        throw Exception(
          'Failed to create order. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in createOrder: $e');

      // Return error response for different types of exceptions
      if (e.toString().contains('timeout')) {
        return OrderResponse(
          success: false,
          error: 'Connection timeout - please try again',
        );
      } else if (e.toString().contains('SocketException')) {
        return OrderResponse(
          success: false,
          error: 'No internet connection - please check your network',
        );
      } else {
        return OrderResponse(
          success: false,
          error: 'Error creating order: ${e.toString()}',
        );
      }
    }
  }

  /// Get all orders for a specific user
  ///
  /// [userId] - The ID of the user whose orders to retrieve
  /// [page] - Page number for pagination (optional)
  /// [limit] - Number of orders per page (optional)
  ///
  /// Returns [Map<String, dynamic>] containing orders data
  static Future<Map<String, dynamic>> getUserOrders({
    required int userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl?user_id=$userId&page=$page&limit=$limit',
      );

      print('📡 Fetching user orders from: $url');

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData; // Return the original JSON response directly
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No orders found for this user',
          'data': {'orders': [], 'total': 0},
        };
      } else {
        throw Exception(
          'Failed to load orders. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getUserOrders: $e');
      return {
        'success': false,
        'error': 'Error loading orders: ${e.toString()}',
      };
    }
  }

  /// Get order details by ID
  ///
  /// [orderId] - The ID of the order to retrieve
  ///
  /// Returns [Map<String, dynamic>] containing order details
  static Future<Map<String, dynamic>> getOrderById({
    required int orderId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/orders/$orderId');

      print('📡 Fetching order details from: $url');

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return {'success': true, 'data': jsonData};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Order not found'};
      } else {
        throw Exception(
          'Failed to load order. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getOrderById: $e');
      return {
        'success': false,
        'error': 'Error loading order: ${e.toString()}',
      };
    }
  }

  /// Update order status (for admin use)
  ///
  /// [orderId] - The ID of the order to update
  /// [status] - New status for the order
  ///
  /// Returns [Map<String, dynamic>] containing update result
  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/orders/$orderId/status');

      final body = {'status': status};

      print('📡 Updating order status: $orderId -> $status');

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
        '📡 Update status response: ${response.statusCode} - ${response.body}',
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Order status updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update order status',
        };
      }
    } catch (e) {
      print('❌ Error in updateOrderStatus: $e');
      return {
        'success': false,
        'message': 'Error updating order status: ${e.toString()}',
      };
    }
  }

  /// Cancel an order
  ///
  /// [orderId] - The ID of the order to cancel
  /// [reason] - Reason for cancellation (optional)
  ///
  /// Returns [Map<String, dynamic>] containing cancellation result
  static Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
    String? reason,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/orders/$orderId/cancel');

      final body = {if (reason != null) 'reason': reason};

      print('📡 Cancelling order: $orderId');

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
        '📡 Cancel order response: ${response.statusCode} - ${response.body}',
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Order cancelled successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      print('❌ Error in cancelOrder: $e');
      return {
        'success': false,
        'message': 'Error cancelling order: ${e.toString()}',
      };
    }
  }

  /// Upload transfer proof for an order
  ///
  /// [orderId] - The ID of the order to upload proof for
  /// [imagePath] - Local path to the transfer proof image
  ///
  /// Returns [Map<String, dynamic>] containing upload result
  static Future<Map<String, dynamic>> uploadTransferProof({
    required int orderId,
    required String imagePath,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$orderId/transfer-proof');

      print('📡 Uploading transfer proof for order: $orderId');
      print('📡 Image path: $imagePath');

      // Create multipart request for file upload
      var multipartRequest = http.MultipartRequest('POST', url);

      // Add headers
      multipartRequest.headers.addAll({'Accept': 'application/json'});

      // Add the image file
      var file = await http.MultipartFile.fromPath(
        'transfer_proof',
        imagePath,
      );
      multipartRequest.files.add(file);

      print('📡 Sending transfer proof to: $url');

      // Send the request with timeout
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout - please check your connection');
        },
      );

      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload response status: ${response.statusCode}');
      print('📡 Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Transfer proof uploaded successfully',
          'data': responseData['data'],
        };
      } else {
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to upload transfer proof',
        };
      }
    } catch (e) {
      print('❌ Error in uploadTransferProof: $e');
      return {
        'success': false,
        'message': 'Error uploading transfer proof: ${e.toString()}',
      };
    }
  }

  /// Helper method to create order from cart items
  ///
  /// [userId] - The user ID
  /// [cartItems] - List of cart items to convert to order items
  /// [shippingMethod] - Selected shipping method
  /// [shippingAddress] - Delivery address
  /// [shippingCost] - Cost of shipping
  ///
  /// Returns [CreateOrderRequest] ready to be sent to createOrder
  static CreateOrderRequest createOrderFromCart({
    required int userId,
    required List<dynamic> cartItems, // Cart items from CartProvider
    required String shippingMethod,
    required String shippingAddress,
    required double shippingCost,
  }) {
    List<OrderItem> orderItems = cartItems.map((cartItem) {
      return OrderItem(
        productId: cartItem.productId ?? 0,
        quantity: cartItem.quantity ?? 0,
        unitPrice: cartItem.priceAsDouble ?? 0.0,
      );
    }).toList();

    return CreateOrderRequest(
      userId: userId,
      shippingMethod: shippingMethod,
      shippingAddress: shippingAddress,
      shippingCost: shippingCost,
      items: orderItems,
    );
  }

  /// Validate order data before sending
  ///
  /// [request] - CreateOrderRequest to validate
  ///
  /// Returns [String?] error message if validation fails, null if valid
  static String? validateOrderRequest(CreateOrderRequest request) {
    if (request.userId <= 0) {
      return 'Valid user ID is required';
    }

    if (request.shippingMethod.trim().isEmpty) {
      return 'Shipping method is required';
    }

    if (request.shippingAddress.trim().isEmpty) {
      return 'Shipping address is required';
    }

    if (request.shippingCost < 0) {
      return 'Shipping cost cannot be negative';
    }

    if (request.items.isEmpty) {
      return 'At least one item is required';
    }

    for (var item in request.items) {
      if (item.productId <= 0) {
        return 'Valid product ID is required for all items';
      }
      if (item.quantity <= 0) {
        return 'Quantity must be greater than 0 for all items';
      }
      if (item.unitPrice <= 0) {
        return 'Unit price must be greater than 0 for all items';
      }
    }

    return null; // Validation passed
  }
}
