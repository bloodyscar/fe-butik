import 'product.dart';
import 'pagination.dart';

class ProductResponse {
  final bool success;
  final String? message;
  final List<Product> products;
  final Pagination? pagination;
  final Map<String, dynamic>? errors;

  ProductResponse({
    required this.success,
    this.message,
    required this.products,
    this.pagination,
    this.errors,
  });

  // Factory constructor to create ProductResponse from JSON
  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    List<Product> productList = [];
    Pagination? paginationData;

    if (json['data'] != null) {
      final data = json['data'] as Map<String, dynamic>;

      // Parse products array
      if (data['products'] != null && data['products'] is List) {
        productList = (data['products'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
      }

      // Parse pagination
      if (data['pagination'] != null) {
        paginationData = Pagination.fromJson(data['pagination']);
      }
    }

    return ProductResponse(
      success: json['success'] ?? false,
      message: json['message'],
      products: productList,
      pagination: paginationData,
      errors: json['errors'],
    );
  }

  // Method to convert ProductResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'products': products.map((product) => product.toJson()).toList(),
        'pagination': pagination?.toJson(),
      },
      'errors': errors,
    };
  }

  @override
  String toString() {
    return 'ProductResponse{success: $success, message: $message, products: ${products.length}, pagination: $pagination}';
  }

  // Helper getter to check if there are products
  bool get hasProducts => products.isNotEmpty;

  // Helper getter to get total count
  int get totalCount => pagination?.totalProducts ?? products.length;
}
