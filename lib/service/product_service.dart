import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/product_response.dart';

class ProductService {
  // API base URL for products
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

  // Helper method to convert filter strings from UI to API format
  static String? _formatFilterForAPI(String? filter, String allOption) {
    if (filter == null || filter.isEmpty || filter == allOption) {
      return null;
    }

    // Handle size filters that have format like "Small (S)"
    if (filter.contains('(') && filter.contains(')')) {
      // Extract the part in parentheses
      final match = RegExp(r'\(([^)]+)\)').firstMatch(filter);
      if (match != null) {
        return match.group(1); // Return just "S" from "Small (S)"
      }
    }

    return filter;
  }
}
