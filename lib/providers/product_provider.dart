import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/product_response.dart';
import '../models/dashboard_response.dart';
import '../service/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _allProducts = []; // Store all products for filtering
  bool _isLoading = false;
  String? _errorMessage;
  ProductResponse? _lastResponse;

  // Dashboard data
  DashboardResponse? _dashboardResponse;
  bool _isDashboardLoading = false;
  String? _dashboardError;

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
  List<Product> get allProducts => _allProducts;
  int get filteredProductsCount => _products.length;
  int get totalProductsCount => _allProducts.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductResponse? get lastResponse => _lastResponse;
  int get currentPage => _currentPage;
  int get totalPages => _lastResponse?.pagination?.totalPages ?? 1;
  int get totalProducts => _lastResponse?.pagination?.totalProducts ?? 0;
  bool get hasNextPage => _lastResponse?.pagination?.hasNext ?? false;
  bool get hasPrevPage => _lastResponse?.pagination?.hasPrev ?? false;

  // Dashboard getters
  DashboardResponse? get dashboardResponse => _dashboardResponse;
  DashboardData? get dashboardData => _dashboardResponse?.data;
  bool get isDashboardLoading => _isDashboardLoading;
  String? get dashboardError => _dashboardError;

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
          _allProducts = response.products; // Store all products
          _products = response.products;
        } else {
          // Append for pagination
          _allProducts.addAll(response.products);
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

  // Set filters and filter from local products
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

    // Filter from existing products
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to _allProducts and update _products
  void _applyFilters() {
    List<Product> filteredProducts = List.from(_allProducts);

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty && _selectedCategory != 'All Categories') {
      filteredProducts = filteredProducts.where((product) => 
        product.category.toLowerCase() == _selectedCategory!.toLowerCase()
      ).toList();
    }

    // Apply age range filter
    if (_selectedAgeRange != null && _selectedAgeRange!.isNotEmpty && _selectedAgeRange != 'All Ages') {
      filteredProducts = filteredProducts.where((product) => 
        product.ageRange.toLowerCase() == _selectedAgeRange!.toLowerCase()
      ).toList();
    }

    // Apply size filter
    if (_selectedSize != null && _selectedSize!.isNotEmpty && _selectedSize != 'All Sizes') {
      filteredProducts = filteredProducts.where((product) => 
        product.size.toLowerCase() == _selectedSize!.toLowerCase()
      ).toList();
    }

    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      filteredProducts = filteredProducts.where((product) => 
        product.name.toLowerCase().contains(query) ||
        product.description.toLowerCase().contains(query) ||
        product.category.toLowerCase().contains(query)
      ).toList();
    }

    // Apply price range filter
    if (_minPrice != null) {
      filteredProducts = filteredProducts.where((product) {
        final productPrice = double.tryParse(product.price) ?? 0.0;
        return productPrice >= _minPrice!;
      }).toList();
    }

    if (_maxPrice != null) {
      filteredProducts = filteredProducts.where((product) {
        final productPrice = double.tryParse(product.price) ?? 0.0;
        return productPrice <= _maxPrice!;
      }).toList();
    }

    // Apply stock filter
    if (_inStock != null) {
      if (_inStock == true) {
        filteredProducts = filteredProducts.where((product) => 
          product.stock > 0
        ).toList();
      } else {
        filteredProducts = filteredProducts.where((product) => 
          product.stock == 0
        ).toList();
      }
    }

    _products = filteredProducts;
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

    // Reset to show all products
    _products = List.from(_allProducts);
    notifyListeners();
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Filter by age range
  Future<void> filterByAgeRange(String ageRange) async {
    _selectedAgeRange = ageRange;
    _applyFilters();
    notifyListeners();
  }

  // Filter by size
  Future<void> filterBySize(String size) async {
    _selectedSize = size;
    _applyFilters();
    notifyListeners();
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

  // Delete a product
  Future<Map<String, dynamic>> deleteProduct(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ProductService.deleteProduct(productId);

      _isLoading = false;

      if (response['success'] == true) {
        
        return {
          'success': true,
          'message': response['message'],
        };
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        
        return {
          'success': false,
          'message': response['message'],
        };
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': false,
        'message': 'Failed to delete product: $e',
      };
    }
  }

  // Update a product
  Future<Map<String, dynamic>> updateProduct({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ProductService.updateProduct(
        id: id,
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
        // Update the product in the local list
        final updatedProduct = response['product'];
        final index = _products.indexWhere((product) => product.id == id);
        if (index != -1) {
          _products[index] = updatedProduct;
          notifyListeners();
        }
        
        return {
          'success': true,
          'message': response['message'],
          'product': updatedProduct,
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
        'message': 'Failed to update product: $e',
        'product': null,
      };
    }
  }

  // Initialize - load products for the first time
  Future<void> initialize() async {
    await loadProducts(reset: true);
  }

  // Load dashboard status
  Future<void> loadDashboardStatus() async {
    _isDashboardLoading = true;
    _dashboardError = null;
    notifyListeners();

    try {
      final response = await ProductService.dashboardStatus();

      if (response.success) {
        _dashboardResponse = response;
        _dashboardError = null;
      } else {
        _dashboardError = response.message ?? 'Failed to load dashboard data';
        _dashboardResponse = null;
      }
    } catch (e) {
      _dashboardError = 'Error loading dashboard: ${e.toString()}';
      _dashboardResponse = null;
    }

    _isDashboardLoading = false;
    notifyListeners();
  }

  // Clear dashboard error
  void clearDashboardError() {
    _dashboardError = null;
    notifyListeners();
  }
}
