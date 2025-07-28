class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final String category;
  final String ageRange;
  final String size;
  final String image;
  final int stock;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.ageRange,
    required this.size,
    required this.image,
    required this.stock,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toString(), // Convert number to string
      category: json['category'] ?? '',
      ageRange: json['age_range'] ?? json['ageRange'] ?? '',
      size: json['size'] ?? '',
      image: json['image'] ?? json['image'] ?? '',
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // Method to convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'age_range': ageRange,
      'size': size,
      'image': image,
      'stock': stock,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, category: $category, ageRange: $ageRange, size: $size, stock: $stock}';
  }

  // Helper method to check if product is in stock
  bool get inStock => stock > 0;
}
