import 'package:butik_evanty/pages/user/home_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';

class CheckoutUser extends StatefulWidget {
  const CheckoutUser({super.key});

  @override
  State<CheckoutUser> createState() => _CheckoutUserState();
}

class _CheckoutUserState extends State<CheckoutUser> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  String? _selectedPaymentMethod;
  String? _selectedShippingMethod;

  // Payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'bca',
      'name': 'Bank BCA',
      'account': '1234567890',
      'accountName': 'Butik Evanty',
      'icon': Icons.account_balance,
      'color': Colors.blue,
    },
    {
      'id': 'bni',
      'name': 'Bank BNI',
      'account': '0987654321',
      'accountName': 'Butik Evanty',
      'icon': Icons.account_balance,
      'color': Colors.orange,
    },
    {
      'id': 'mandiri',
      'name': 'Bank Mandiri',
      'account': '1122334455',
      'accountName': 'Butik Evanty',
      'icon': Icons.account_balance,
      'color': Colors.yellow[700],
    },
    {
      'id': 'bri',
      'name': 'Bank BRI',
      'account': '5544332211',
      'accountName': 'Butik Evanty',
      'icon': Icons.account_balance,
      'color': Colors.red,
    },
  ];

  // Shipping methods
  final List<Map<String, dynamic>> _shippingMethods = [
    {
      'id': 'jne_regular',
      'name': 'JNE Regular',
      'description': '2-3 hari kerja',
      'cost': 15000.0,
      'icon': Icons.local_shipping,
    },
    {
      'id': 'jne_express',
      'name': 'JNE Express',
      'description': '1-2 hari kerja',
      'cost': 25000.0,
      'icon': Icons.flash_on,
    },
    {
      'id': 'jnt_regular',
      'name': 'J&T Regular',
      'description': '2-4 hari kerja',
      'cost': 12000.0,
      'icon': Icons.local_shipping,
    },
    {
      'id': 'jnt_express',
      'name': 'J&T Express',
      'description': '1-2 hari kerja',
      'cost': 20000.0,
      'icon': Icons.flash_on,
    },
    {
      'id': 'cod_local',
      'name': 'COD Lokal',
      'description': 'Bayar di tempat (khusus area Jakarta)',
      'cost': 5000.0,
      'icon': Icons.money,
    },
  ];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer3<CartProvider, OrderProvider, AuthProvider>(
        builder: (context, cartProvider, orderProvider, authProvider, child) {
          if (cartProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Section
                  _buildOrderSummarySection(cartProvider),

                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

                  // Shipping Address Section
                  _buildShippingAddressSection(),

                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

                  // Shipping Method Section
                  _buildShippingMethodSection(),

                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

                  // Payment Method Section
                  _buildPaymentMethodSection(),

                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

                  // Final Summary and Place Order
                  _buildFinalSummarySection(cartProvider, orderProvider),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer3<CartProvider, OrderProvider, AuthProvider>(
        builder: (context, cartProvider, orderProvider, authProvider, child) {
          return Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed:
                    cartProvider.isNotEmpty && !orderProvider.isCreatingOrder
                    ? () =>
                          _placeOrder(cartProvider, orderProvider, authProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: orderProvider.isCreatingOrder
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing Order...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment),
                          const SizedBox(width: 8),
                          Text(
                            'Place Order - ${_calculateTotal(cartProvider)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummarySection(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...cartProvider.allCartItems.map((item) => _buildOrderItem(item)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${cartProvider.totalItemsCount} items)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                cartProvider.formattedTotalAmount,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: item.productImage != null && item.productImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://10.0.2.2:3000/${item.productImage}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 24);
                      },
                    ),
                  )
                : const Icon(Icons.shopping_bag_outlined, size: 24),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unknown Product',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.formattedPrice} x ${item.quantity}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Subtotal
          Text(
            item.formattedSubtotal,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Complete Address',
              hintText: 'Enter your complete shipping address',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Shipping address is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShippingMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Method',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._shippingMethods.map((method) => _buildShippingMethodCard(method)),
        ],
      ),
    );
  }

  Widget _buildShippingMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedShippingMethod == method['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedShippingMethod = method['id'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                method['icon'],
                color: isSelected ? Colors.blue[600] : Colors.grey[600],
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[600] : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['description'],
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp ${method['cost'].toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue[600] : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Radio<String>(
                value: method['id'],
                groupValue: _selectedShippingMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedShippingMethod = value;
                  });
                },
                activeColor: Colors.blue[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method['id'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: method['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(method['icon'], color: method['color'], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[600] : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${method['account']} - ${method['accountName']}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: method['id'],
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                activeColor: Colors.blue[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalSummarySection(
    CartProvider cartProvider,
    OrderProvider orderProvider,
  ) {
    final selectedShipping = _shippingMethods.firstWhere(
      (method) => method['id'] == _selectedShippingMethod,
      orElse: () => {'cost': 0.0},
    );

    final subtotal = cartProvider.totalAmount;
    final shippingCost = selectedShipping['cost'] ?? 0.0;
    final total = subtotal + shippingCost;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Total',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary rows
          _buildSummaryRow('Subtotal', 'Rp ${subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow(
            'Shipping Cost',
            _selectedShippingMethod != null
                ? 'Rp ${shippingCost.toStringAsFixed(0)}'
                : 'Select shipping method',
          ),
          const Divider(),
          _buildSummaryRow(
            'Total',
            'Rp ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),

          if (orderProvider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderProvider.errorMessage!,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue[600] : null,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotal(CartProvider cartProvider) {
    final selectedShipping = _shippingMethods.firstWhere(
      (method) => method['id'] == _selectedShippingMethod,
      orElse: () => {'cost': 0.0},
    );

    final subtotal = cartProvider.totalAmount;
    final shippingCost = selectedShipping['cost'] ?? 0.0;
    final total = subtotal + shippingCost;

    return 'Rp ${total.toStringAsFixed(2)}';
  }

  Future<void> _placeOrder(
    CartProvider cartProvider,
    OrderProvider orderProvider,
    AuthProvider authProvider,
  ) async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedShippingMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shipping method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = authProvider.user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get selected shipping method details
    final selectedShipping = _shippingMethods.firstWhere(
      (method) => method['id'] == _selectedShippingMethod,
    );

    // Set user ID in order provider
    orderProvider.setCurrentUserId(userId);

    // Create order request
    final orderItems = cartProvider.allCartItems.map((cartItem) {
      return OrderItem(
        productId: cartItem.productId,
        quantity: cartItem.quantity,
        unitPrice: cartItem.priceAsDouble,
      );
    }).toList();

    final orderRequest = CreateOrderRequest(
      userId: userId,
      shippingMethod: selectedShipping['name'],
      shippingAddress: _addressController.text.trim(),
      shippingCost: selectedShipping['cost'],
      items: orderItems,
    );

    // Place order
    final success = await orderProvider.createOrder(orderRequest: orderRequest);

    if (mounted) {
      if (success) {
        // Calculate total BEFORE clearing cart
        final orderTotal = _calculateTotal(cartProvider);

        // Clear cart after successful order using removeFromCart for each item
        final cartClearSuccess = await cartProvider.clearAllCartItems();

        if (!cartClearSuccess) {
          print(
            '⚠️ Warning: Failed to clear cart items after successful order',
          );
        }

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Order Placed!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your order has been placed successfully. Please upload your payment proof to complete the order in order page',
                  ),
                  const SizedBox(height: 12),
                  if (orderProvider.currentOrder?.id != null)
                    Text(
                      'Order ID: #${orderProvider.currentOrder!.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: $orderTotal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeUser()),
                      (route) => false,
                    ); // Go back to cart/home
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Error is already shown by the provider via errorMessage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.errorMessage ?? 'Failed to place order',
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}
