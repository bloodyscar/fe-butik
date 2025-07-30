class DashboardResponse {
  final bool success;
  final String? message;
  final DashboardData? data;

  DashboardResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class DashboardData {
  final DashboardSummary summary;
  final String timestamp;

  DashboardData({
    required this.summary,
    required this.timestamp,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summary: DashboardSummary.fromJson(json['summary']),
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'timestamp': timestamp,
    };
  }
}

class DashboardSummary {
  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final double totalRevenue;

  DashboardSummary({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalRevenue,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalProducts: json['total_products'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'total_orders': totalOrders,
      'total_users': totalUsers,
      'total_revenue': totalRevenue,
    };
  }
}
