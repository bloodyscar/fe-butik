import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/product_response.dart';
import '../service/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  ProductResponse? _lastResponse;

  // Current filter state
  int _currentPage = 1;
  int _limit = 10;
  String? _selectedCategory;
  String? _selectedAgeRange;
  String? _selectedSize;
  String? _searchQuery;
  double? _minPrice;
  double? _maxPrice;
  bool? _inStock;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductResponse? get lastResponse => _lastResponse;
  int get currentPage => _currentPage;
  int get totalPages => _lastResponse?.pagination?.totalPages ?? 1;
  int get totalProducts => _lastResponse?.pagination?.totalProducts ?? 0;
  bool get hasNextPage => _lastResponse?.pagination?.hasNext ?? false;
  bool get hasPrevPage => _lastResponse?.pagination?.hasPrev ?? false;

  // Filter getters
  String? get selectedCategory => _selectedCategory;
  String? get selectedAgeRange => _selectedAgeRange;
  String? get selectedSize => _selectedSize;
  String? get searchQuery => _searchQuery;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  bool? get inStock => _inStock;

  // Load products with current filters
  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _products.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ProductService.getAllProducts(
        page: _currentPage,
        limit: _limit,
        category: _selectedCategory,
        ageRange: _selectedAgeRange,
        size: _selectedSize,
        search: _searchQuery,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        inStock: _inStock,
      );

      _lastResponse = response;

      if (response.success) {
        if (reset || _currentPage == 1) {
          _products = response.products;
        } else {
          // Append for pagination
          _products.addAll(response.products);
        }
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to load products';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load next page (pagination)
  Future<void> loadNextPage() async {
    if (!hasNextPage || _isLoading) return;

    _currentPage++;
    await loadProducts();
  }

  // Load previous page
  Future<void> loadPreviousPage() async {
    if (!hasPrevPage || _isLoading || _currentPage <= 1) return;

    _currentPage--;
    await loadProducts(reset: true);
  }

  // Set filters and reload
  Future<void> setFilters({
    String? category,
    String? ageRange,
    String? size,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) async {
    _selectedCategory = category;
    _selectedAgeRange = ageRange;
    _selectedSize = size;
    _searchQuery = search;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _inStock = inStock;

    await loadProducts(reset: true);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _selectedCategory = null;
    _selectedAgeRange = null;
    _selectedSize = null;
    _searchQuery = null;
    _minPrice = null;
    _maxPrice = null;
    _inStock = null;

    await loadProducts(reset: true);
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    await loadProducts(reset: true);
  }

  // Filter by category
  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    await loadProducts(reset: true);
  }

  // Filter by age range
  Future<void> filterByAgeRange(String ageRange) async {
    _selectedAgeRange = ageRange;
    await loadProducts(reset: true);
  }

  // Filter by size
  Future<void> filterBySize(String size) async {
    _selectedSize = size;
    await loadProducts(reset: true);
  }

  // Get product by ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh products (pull to refresh)
  Future<void> refreshProducts() async {
    await loadProducts(reset: true);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Create a new product
  Future<Map<String, dynamic>> createProduct({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ProductService.createProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        ageRange: ageRange,
        ageRangeId: ageRangeId,
        size: size,
        sizeId: sizeId,
        customSize: customSize,
        imageFile: imageFile,
      );

      _isLoading = false;

      if (response['success'] == true && response['product'] != null) {
        // Add the new product to the beginning of the list
        _products.insert(0, response['product']);
        notifyListeners();
        
        return {
          'success': true,
          'message': response['message'],
          'product': response['product'],
        };
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        
        return {
          'success': false,
          'message': response['message'],
          'product': null,
        };
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': false,
        'message': 'Failed to create product: $e',
        'product': null,
      };
    }
  }

  // Initialize - load products for the first time
  Future<void> initialize() async {
    await loadProducts(reset: true);
  }
}
