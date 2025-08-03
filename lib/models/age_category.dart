class AgeCategory {
  final int id;
  final String label;

  AgeCategory({
    required this.id,
    required this.label,
  });

  // Factory constructor to create AgeCategory from JSON
  factory AgeCategory.fromJson(Map<String, dynamic> json) {
    return AgeCategory(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
    );
  }

  // Method to convert AgeCategory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
    };
  }

  @override
  String toString() {
    return 'AgeCategory(id: $id, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgeCategory &&
        other.id == id &&
        other.label == label;
  }

  @override
  int get hashCode {
    return id.hashCode ^ label.hashCode;
  }
}

class AgeCategoriesResponse {
  final bool success;
  final String? message;
  final List<AgeCategory> ageCategories;
  final Map<String, dynamic>? errors;

  AgeCategoriesResponse({
    required this.success,
    this.message,
    required this.ageCategories,
    this.errors,
  });

  // Factory constructor to create AgeCategoriesResponse from JSON
  factory AgeCategoriesResponse.fromJson(Map<String, dynamic> json) {
    List<AgeCategory> categories = [];

    if (json['data'] != null && json['data']['age_categories'] != null) {
      final categoriesData = json['data']['age_categories'] as List;
      categories = categoriesData
          .map((categoryJson) => AgeCategory.fromJson(categoryJson))
          .toList();
    }

    return AgeCategoriesResponse(
      success: json['success'] ?? false,
      message: json['message'],
      ageCategories: categories,
      errors: json['errors'],
    );
  }

  // Method to convert AgeCategoriesResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'age_categories': ageCategories.map((category) => category.toJson()).toList(),
      },
      'errors': errors,
    };
  }
}
