class SizeCategory {
  final int id;
  final String label;
  final bool isCustom;
  final int? customValueCm;

  SizeCategory({
    required this.id,
    required this.label,
    required this.isCustom,
    this.customValueCm,
  });

  // Factory constructor to create SizeCategory from JSON
  factory SizeCategory.fromJson(Map<String, dynamic> json) {
    return SizeCategory(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      isCustom: (json['is_custom'] == 1 || json['is_custom'] == true),
      customValueCm: json['custom_value_cm'],
    );
  }

  // Method to convert SizeCategory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'is_custom': isCustom ? 1 : 0,
      'custom_value_cm': customValueCm,
    };
  }

  @override
  String toString() {
    return 'SizeCategory(id: $id, label: $label, isCustom: $isCustom, customValueCm: $customValueCm)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SizeCategory &&
        other.id == id &&
        other.label == label &&
        other.isCustom == isCustom &&
        other.customValueCm == customValueCm;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        isCustom.hashCode ^
        customValueCm.hashCode;
  }
}

class SizeCategoriesResponse {
  final bool success;
  final String? message;
  final List<SizeCategory> sizeCategories;
  final Map<String, dynamic>? errors;

  SizeCategoriesResponse({
    required this.success,
    this.message,
    required this.sizeCategories,
    this.errors,
  });

  // Factory constructor to create SizeCategoriesResponse from JSON
  factory SizeCategoriesResponse.fromJson(Map<String, dynamic> json) {
    List<SizeCategory> categories = [];

    if (json['data'] != null && json['data']['size_categories'] != null) {
      final categoriesData = json['data']['size_categories'] as List;
      categories = categoriesData
          .map((categoryJson) => SizeCategory.fromJson(categoryJson))
          .toList();
    }

    return SizeCategoriesResponse(
      success: json['success'] ?? false,
      message: json['message'],
      sizeCategories: categories,
      errors: json['errors'],
    );
  }

  // Method to convert SizeCategoriesResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'size_categories': sizeCategories.map((category) => category.toJson()).toList(),
      },
      'errors': errors,
    };
  }
}
