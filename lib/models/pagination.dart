class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalProducts,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  // Factory constructor to create Pagination from JSON
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      totalProducts: json['total_products'] ?? json['totalProducts'] ?? 0,
      limit: json['limit'] ?? 10,
      hasNext: json['has_next'] ?? json['hasNext'] ?? false,
      hasPrev: json['has_prev'] ?? json['hasPrev'] ?? false,
    );
  }

  // Method to convert Pagination to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_products': totalProducts,
      'limit': limit,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }

  @override
  String toString() {
    return 'Pagination{currentPage: $currentPage, totalPages: $totalPages, totalProducts: $totalProducts, limit: $limit, hasNext: $hasNext, hasPrev: $hasPrev}';
  }
}
