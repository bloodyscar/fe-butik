import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'session_manager.dart';
import 'package:http_parser/http_parser.dart';

class OrderService {
  static const String baseUrl = 'http://157.66.34.221:8081/orders';

  /// Get headers with authentication token
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await SessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Get headers for multipart requests with authentication token
  static Future<Map<String, String>> _getMultipartHeaders() async {
    final headers = {
      'Accept': 'application/json',
    };

    final token = await SessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

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

      // Get authenticated headers
      final headers = await _getMultipartHeaders();
      multipartRequest.headers.addAll(headers);

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

      // Get authenticated headers
      final headers = await _getHeaders();

      final response = await http
          .get(
            url,
            headers: headers,
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
      final url = Uri.parse('$baseUrl/$orderId');

      print('📡 Fetching order details from: $url');

      // Get authenticated headers
      final headers = await _getHeaders();

      final response = await http
          .get(
            url,
            headers: headers,
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

  /// Update order (for admin use and user transfer proof upload)
  ///
  /// [orderId] - The ID of the order to update
  /// [status] - New status for the order (optional, admin only)
  /// [transferProof] - Transfer proof image file path (optional, user upload)
  ///
  /// Returns [Map<String, dynamic>] containing update result
  static Future<Map<String, dynamic>> updateOrder({
    required int orderId,
    String? status,
    File? transferProof,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$orderId');

      print('📡 Updating order: $orderId${status != null ? ' -> $status' : ''}${transferProof != null ? ' with transfer proof' : ''}${status == null && transferProof == null ? ' (no changes)' : ''}');

      // Create multipart request for file upload support
      var multipartRequest = http.MultipartRequest('PUT', url);

      // Get authenticated headers
      final headers = await _getMultipartHeaders();
      multipartRequest.headers.addAll(headers);

      // Add form fields
      if (status != null) {
        multipartRequest.fields['status'] = status;
      }

      // Handle image file if provided
      if (transferProof != null) {
        String mimeType = '';
        if (transferProof.path.endsWith('.jpg') || transferProof.path.endsWith('.jpeg')) {
          mimeType = 'jpeg';
        } else if (transferProof.path.endsWith('.png')) {
          mimeType = 'png';
        }

        multipartRequest.files.add(
          await http.MultipartFile.fromPath('image', transferProof.path, contentType: MediaType('image', mimeType)),
        );

        multipartRequest.fields['status'] = "dikirim";
      }

      print('📡 Sending update request to: $url');
      print('📋 Update fields: ${multipartRequest.fields}');

      // Send the request with timeout
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your connection');
        },
      );

      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);

      print(
        '📡 Update order response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ?? 'Order updated successfully',
            'data': responseData['data'],
          };
        } catch (parseError) {
          return {
            'success': true,
            'message': 'Order updated successfully',
          };
        }
      } else {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to update order',
          };
        } catch (parseError) {
          return {
            'success': false,
            'message': 'Failed to update order: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('❌ Error in updateOrder: $e');
      return {
        'success': false,
        'message': 'Error updating order: ${e.toString()}',
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

      // Get authenticated headers
      final headers = await _getHeaders();

      final response = await http
          .put(
            url,
            headers: headers,
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
      final url = Uri.parse('$baseUrl/$orderId');

      print('📡 Uploading transfer proof for order: $orderId');
      print('📡 Image path: $imagePath');

      // Create multipart request for file upload
      var multipartRequest = http.MultipartRequest('POST', url);

      // Get authenticated headers
      final headers = await _getMultipartHeaders();
      multipartRequest.headers.addAll(headers);

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

  /// Get all orders for admin management
  ///
  /// Returns [AllOrdersResponse] containing list of all orders
  static Future<AllOrdersResponse> getAllOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? userId,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (userId != null && userId.isNotEmpty) {
        queryParams['user_id'] = userId;
      }

      // Build URI with query parameters
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      print('📡 Fetching all orders from: $uri');

      // Get authenticated headers
      final headers = await _getHeaders();

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your connection');
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body preview: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}...');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('📋 Parsed JSON structure: ${responseData.keys.toList()}');
        
        final result = AllOrdersResponse.fromJson(responseData);
        print('✅ Successfully parsed ${result.orders.length} orders');
        print('📊 Pagination: Page ${result.currentPage}/${result.totalPages}, Total: ${result.totalOrders}');
        
        return result;
      } else {
        final errorData = jsonDecode(response.body);
        return AllOrdersResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch orders',
          orders: [],
          errors: errorData['errors'] ?? {},
        );
      }
    } catch (e) {
      print('❌ Error in getAllOrders: $e');
      return AllOrdersResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        orders: [],
        errors: {'network': e.toString()},
      );
    }
  }

  /// Delete an order by ID (for admin use)
  ///
  /// [orderId] - The ID of the order to delete
  ///
  /// Returns [Map<String, dynamic>] containing deletion result
  static Future<Map<String, dynamic>> deleteOrder({
    required int orderId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$orderId');

      print('📡 Deleting order: $orderId');

      // Get authenticated headers
      final headers = await _getHeaders();

      final response = await http
          .delete(
            url,
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your connection');
            },
          );

      print(
        '📡 Delete order response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        try {
          // Try to parse response if it has content
          if (response.body.isNotEmpty) {
            final responseData = json.decode(response.body);
            return {
              'success': true,
              'message': responseData['message'] ?? 'Order deleted successfully',
              'data': responseData['data'],
            };
          } else {
            // No content response (204)
            return {
              'success': true,
              'message': 'Order deleted successfully',
            };
          }
        } catch (parseError) {
          // If parsing fails but status is success, still return success
          return {
            'success': true,
            'message': 'Order deleted successfully',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Order not found',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Access denied - admin privileges required',
        };
      } else {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to delete order',
          };
        } catch (parseError) {
          return {
            'success': false,
            'message': 'Failed to delete order: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('❌ Error in deleteOrder: $e');
      return {
        'success': false,
        'message': 'Error deleting order: ${e.toString()}',
      };
    }
  }
}
