import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/product.dart';
import '../models/product_response.dart';
import '../models/dashboard_response.dart';

class ProductService {
  // API base URL for products
  // static const String _baseUrl = 'http://10.0.2.2:3000/products';
  static const String _baseUrl = 'http://10.0.2.2:3000/products';

  // Get all products with optional filters and pagination
  static Future<ProductResponse> getAllProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? ageRange,
    String? size,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add optional filters
      if (category != null &&
          category.isNotEmpty &&
          category != 'All Categories') {
        queryParams['category'] = category;
      }
      if (ageRange != null && ageRange.isNotEmpty && ageRange != 'All Ages') {
        queryParams['age_range'] = ageRange;
      }
      if (size != null && size.isNotEmpty && size != 'All Sizes') {
        queryParams['size'] = size;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      if (inStock != null) {
        queryParams['in_stock'] = inStock.toString();
      }

      // Build URI with query parameters
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Success - parse the response
        final responseData = jsonDecode(response.body);
        return ProductResponse.fromJson(responseData);
      } else {
        // Error response
        final errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch products',
          products: [],
          errors: errorData['errors'] ?? {},
        );
      }
    } catch (e) {
      // Network or other error
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        products: [],
        errors: {'network': e.toString()},
      );
    }
  }

  // Get product by ID
  static Future<ProductResponse> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle single product response
        if (responseData['success'] == true && responseData['data'] != null) {
          final product = Product.fromJson(responseData['data']);
          return ProductResponse(
            success: true,
            message: responseData['message'],
            products: [product],
          );
        } else {
          return ProductResponse(
            success: false,
            message: responseData['message'] ?? 'Product not found',
            products: [],
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch product',
          products: [],
          errors: errorData['errors'] ?? {},
        );
      }
    } catch (e) {
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        products: [],
        errors: {'network': e.toString()},
      );
    }
  }

  // Get products by category
  static Future<ProductResponse> getProductsByCategory(
    String category, {
    int page = 1,
    int limit = 10,
  }) async {
    return getAllProducts(page: page, limit: limit, category: category);
  }

  // Get products by age range
  static Future<ProductResponse> getProductsByAgeRange(
    String ageRange, {
    int page = 1,
    int limit = 10,
  }) async {
    return getAllProducts(page: page, limit: limit, ageRange: ageRange);
  }

  // Get products by size
  static Future<ProductResponse> getProductsBySize(
    String size, {
    int page = 1,
    int limit = 10,
  }) async {
    return getAllProducts(page: page, limit: limit, size: size);
  }

  // Search products
  static Future<ProductResponse> searchProducts(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    return getAllProducts(page: page, limit: limit, search: query);
  }

  // Get featured products (this could be a special endpoint or filter)
  static Future<ProductResponse> getFeaturedProducts({int limit = 6}) async {
    return getAllProducts(
      page: 1,
      limit: limit,
      // You could add a 'featured' parameter if your API supports it
    );
  }

  // Get dashboard status with product statistics
  static Future<DashboardResponse> dashboardStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        return DashboardResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch dashboard status',
          data: null,
        );
      }
    } catch (e) {
      return DashboardResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Create a new product
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String ageRange,
    required int ageRangeId,
    required String size,
    required int sizeId,
    required String customSize,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/create'));
      
      // Add form fields
      request.fields.addAll({
        'name': name,
        'description': description,
        'price': price.toString(),
        'stock': stock.toString(),
        'age_category_id': ageRangeId.toString(),
        'size_category_id': sizeId.toString(),
        'age_range': ageRange,
        'size': size == 'Custom' ? customSize : size,
      });

      // Handle image file if provided
      if (imageFile != null) {
        String mimeType = '';
        if (imageFile.path.endsWith('.jpg') || imageFile.path.endsWith('.jpeg')) {
          mimeType = 'jpeg';
        } else if (imageFile.path.endsWith('.png')) {
          mimeType = 'png';
        }

        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path, contentType: MediaType('image', mimeType)),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Server response: $data'); // Debug log
        
        Product? product;
        // Handle different response structures
        try {
          if (data['product'] != null) {
            product = Product.fromJson(data['product']);
          } else if (data['data'] != null) {
            product = Product.fromJson(data['data']);
          } else {
            product = Product.fromJson(data);
          }
        } catch (e) {
          print('Error parsing product: $e');
          print('Raw data: $data');
          return {
            'success': false,
            'message': 'Failed to parse product data: $e',
            'product': null,
          };
        }

        // Return success response with product and message
        return {
          'success': true,
          'message': 'Product "$name" created successfully!',
          'product': product,
        };
      } else {
        final errorData = json.decode(response.body);
        print('Server error response: $errorData'); // Debug log
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create product',
          'product': null,
        };
      }
    } catch (e) {
      print('Exception in createProduct: $e'); // Debug log
      return {
        'success': false,
        'message': 'Failed to create product: $e',
        'product': null,
      };
    }
  }

  // Delete a product by ID
  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.body.isNotEmpty ? json.decode(response.body) : {};
        return {
          'success': true,
          'message': data['message'] ?? 'Product deleted successfully!',
        };
      } else {
        final errorData = json.decode(response.body);
        print('Delete error response: $errorData'); // Debug log
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete product',
        };
      }
    } catch (e) {
      print('Exception in deleteProduct: $e'); // Debug log
      return {
        'success': false,
        'message': 'Failed to delete product: $e',
      };
    }
  }

  // Update/Edit a product by ID
  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String ageRange,
    required int ageRangeId,
    required String size,
    required int sizeId,
    required String customSize,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/$id'));
      
      // Add form fields
      request.fields.addAll({
        'name': name,
        'description': description,
        'price': price.toString(),
        'stock': stock.toString(),
        'age_category_id': ageRangeId.toString(),
        'size_category_id': sizeId.toString(),
        'age_range': ageRange,
        'size': size == 'Custom' ? customSize : size,
      });

      // Handle image file if provided
      if (imageFile != null) {
        String mimeType = '';
        if (imageFile.path.endsWith('.jpg') || imageFile.path.endsWith('.jpeg')) {
          mimeType = 'jpeg';
        } else if (imageFile.path.endsWith('.png')) {
          mimeType = 'png';
        }

        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path, contentType: MediaType('image', mimeType)),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Server response: $data'); // Debug log
        
        Product? product;
        // Handle different response structures
        try {
          if (data['product'] != null) {
            product = Product.fromJson(data['product']);
          } else if (data['data'] != null) {
            product = Product.fromJson(data['data']);
          } else {
            product = Product.fromJson(data);
          }
        } catch (e) {
          print('Error parsing product: $e');
          print('Raw data: $data');
          return {
            'success': false,
            'message': 'Failed to parse product data: $e',
            'product': null,
          };
        }

        // Return success response with product and message
        return {
          'success': true,
          'message': 'Product "$name" updated successfully!',
          'product': product,
        };
      } else {
        final errorData = json.decode(response.body);
        print('Server error response: $errorData'); // Debug log
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update product',
          'product': null,
        };
      }
    } catch (e) {
      print('Exception in updateProduct: $e'); // Debug log
      return {
        'success': false,
        'message': 'Failed to update product: $e',
        'product': null,
      };
    }
  }
}
