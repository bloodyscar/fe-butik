import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/product.dart';
import '../../models/size_category.dart';
import '../../models/age_category.dart';
import '../../service/session_manager.dart';
import '../../service/product_service.dart';
import '../../utils/price_formatter.dart';
import 'detail_product_page.dart';
import 'cart_user.dart';
import 'order_page.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  String? selectedAgeFilter;
  String? selectedSizeFilter;
  List<SizeCategory> sizeCategories = [];
  bool isLoadingSizeCategories = false;
  List<AgeCategory> ageCategories = [];
  bool isLoadingAgeCategories = false;

  final List<String> categoryFilters = [
    'All Categories',
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Sleepwear',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize ProductProvider when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initialize();
      _initializeOrderData();
      _loadSizeCategories();
      _loadAgeCategories();
    });
  }

  void _loadSizeCategories() async {
    setState(() {
      isLoadingSizeCategories = true;
    });

    try {
      final response = await ProductService.getAllSizeCategories();
      if (response.success) {
        setState(() {
          sizeCategories = response.sizeCategories;
          isLoadingSizeCategories = false;
        });
      } else {
        setState(() {
          isLoadingSizeCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load size categories: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoadingSizeCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading size categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loadAgeCategories() async {
    setState(() {
      isLoadingAgeCategories = true;
    });

    try {
      final response = await ProductService.getAllAgeCategories();
      if (response.success) {
        setState(() {
          ageCategories = response.ageCategories;
          isLoadingAgeCategories = false;
        });
      } else {
        setState(() {
          isLoadingAgeCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load age categories: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoadingAgeCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading age categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<DropdownMenuItem<String>> _buildSizeDropdownItems() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem<String>(
        value: 'All Sizes',
        child: Text(
          'All Sizes',
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    if (isLoadingSizeCategories) {
      items.add(
        const DropdownMenuItem<String>(
          value: null,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Loading sizes...',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    } else {
      // Add size categories from API
      for (final sizeCategory in sizeCategories) {
        items.add(
          DropdownMenuItem<String>(
            value: sizeCategory.label,
            child: Text(
              sizeCategory.label,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    }

    return items;
  }

  List<DropdownMenuItem<String>> _buildAgeDropdownItems() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem<String>(
        value: 'All Ages',
        child: Text(
          'All Ages',
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    if (isLoadingAgeCategories) {
      items.add(
        const DropdownMenuItem<String>(
          value: null,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Loading ages...',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    } else {
      // Add age categories from API
      for (final ageCategory in ageCategories) {
        items.add(
          DropdownMenuItem<String>(
            value: ageCategory.label,
            child: Text(
              ageCategory.label,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    }

    return items;
  }

  void _initializeOrderData() async {
    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (authProvider.user != null && authProvider.user!.id != null) {
      // Set current user ID in order provider
      orderProvider.setCurrentUserId(authProvider.user!.id!);
      // Load user orders silently (don't show loading indicators)
      await orderProvider.loadUserOrders(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Butik Evanty'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Order notification icon
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartUser()),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton(
                icon: const Icon(Icons.account_circle),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(authProvider.user?.name ?? 'User'),
                      subtitle: Text(authProvider.user?.email ?? ''),
                    ),
                  ),
                  const PopupMenuItem(child: Divider()),
                  
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        // First close the popup menu
                        Navigator.of(context).pop();
                        
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Logout'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          // Show loading dialog while logging out
                          await SessionManager.clearSession();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                          
                          
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Welcome to Butik Evanty',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hello, ${authProvider.user?.name ?? 'User'}!',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover adorable clothes for your little ones',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Transfer Proof Notification Banner
                Consumer<OrderProvider>(
                  builder: (context, orderProvider, child) {
                    // Count orders that need transfer proof
                    final ordersNeedingProof = orderProvider.orders.where((order) =>
                      (order.status.toLowerCase() == 'belum bayar') &&
                      (order.transferProof == null || order.transferProof!.isEmpty)
                    ).toList();

                    if (ordersNeedingProof.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: Colors.orange.shade50,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.orange.shade300),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OrderPage()),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange.shade600,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Action Required',
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ordersNeedingProof.length == 1
                                            ? 'You have 1 order waiting for transfer proof upload.'
                                            : 'You have ${ordersNeedingProof.length} orders waiting for transfer proof upload.',
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to view and upload proof →',
                                        style: TextStyle(
                                          color: Colors.orange.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.orange.shade600,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Add spacing only if notification is shown
                Consumer<OrderProvider>(
                  builder: (context, orderProvider, child) {
                    final ordersNeedingProof = orderProvider.orders.where((order) =>
                      (order.status.toLowerCase() == 'belum bayar') &&
                      (order.transferProof == null || order.transferProof!.isEmpty)
                    ).toList();
                    
                    return ordersNeedingProof.isNotEmpty 
                        ? const SizedBox(height: 20) 
                        : const SizedBox.shrink();
                  },
                ),

                // Filter Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.filter_list, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Filter Products',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Age Range',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedAgeFilter,
                                  hint: const Text('Select Age'),
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: _buildAgeDropdownItems(),
                                  onChanged: isLoadingAgeCategories ? null : (String? newValue) {
                                    setState(() {
                                      selectedAgeFilter = newValue;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Size',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedSizeFilter,
                                  hint: const Text('Select Size'),
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: _buildSizeDropdownItems(),
                                  onChanged: isLoadingSizeCategories ? null : (String? newValue) {
                                    setState(() {
                                      selectedSizeFilter = newValue;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                       const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear All'),
                          ),
                          
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Products Section
                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Products Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Products',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (productProvider.products.isNotEmpty)
                                Text(
                                  '${productProvider.products.length} of ${productProvider.totalProducts}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Loading Indicator
                          if (productProvider.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            ),

                          // Error Message
                          if (productProvider.errorMessage != null &&
                              !productProvider.isLoading)
                            Card(
                              color: Colors.red[50],
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Error: ${productProvider.errorMessage}',
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          productProvider.refreshProducts(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Products Grid
                          if (productProvider.products.isNotEmpty &&
                              !productProvider.isLoading)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: productProvider.products.length,
                              itemBuilder: (context, index) {
                                final product = productProvider.products[index];
                                return _buildProductCard(context, product);
                              },
                            ),

                          // Empty State
                          if (productProvider.products.isEmpty &&
                              !productProvider.isLoading &&
                              productProvider.errorMessage == null)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No products found',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your filters or check back later',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[500]),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        _clearFilters();
                                      },
                                      child: const Text('Clear Filters'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Pagination Controls
                          if (productProvider.products.isNotEmpty &&
                              (productProvider.hasNextPage ||
                                  productProvider.hasPrevPage))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed:
                                        productProvider.hasPrevPage &&
                                            !productProvider.isLoading
                                        ? () =>
                                              productProvider.loadPreviousPage()
                                        : null,
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('Previous'),
                                  ),
                                  Text(
                                    'Page ${productProvider.currentPage} of ${productProvider.totalPages}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed:
                                        productProvider.hasNextPage &&
                                            !productProvider.isLoading
                                        ? () => productProvider.loadNextPage()
                                        : null,
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('Next'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailProductPage(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: product.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          "http://157.66.34.221:8081/${product.image}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Age Range and Size
                    Row(
                      children: [
                        if (product.ageRange.isNotEmpty) ...[
                          Icon(
                            Icons.child_care,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              product.ageRange,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (product.ageRange.isNotEmpty &&
                            product.size.isNotEmpty)
                          Text(
                            ' • ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        if (product.size.isNotEmpty)
                          Flexible(
                            child: Text(
                              product.size,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Price and Stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            PriceFormatter.formatPrice(product.price),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.inStock
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.inStock ? 'In Stock' : 'Out of Stock',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: product.inStock
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() async {
    final productProvider = context.read<ProductProvider>();

    // Apply filters using ProductProvider with named parameters
    await productProvider.setFilters(
      ageRange: selectedAgeFilter != null && selectedAgeFilter != 'All Ages'
          ? selectedAgeFilter
          : null,
      size: selectedSizeFilter != null && selectedSizeFilter != 'All Sizes'
          ? selectedSizeFilter
          : null,
    );
  }

  void _clearFilters() async {
    setState(() {
      selectedAgeFilter = null;
      selectedSizeFilter = null;
    });

    // Clear filters using ProductProvider
    await context.read<ProductProvider>().clearFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All filters cleared'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
