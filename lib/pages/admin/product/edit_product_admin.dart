import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../providers/product_provider.dart';
import '../../../models/product.dart';

class EditProductAdmin extends StatefulWidget {
  final Product product;

  const EditProductAdmin({super.key, required this.product});

  @override
  State<EditProductAdmin> createState() => _EditProductAdminState();
}

class _EditProductAdminState extends State<EditProductAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _customSizeController = TextEditingController();

  String? _selectedAgeRange;
  int? _selectedAgeRangeId;
  String? _selectedSize;
  int? _selectedSizeId;
  File? _selectedImage;
  bool _showCustomSize = false;

  // Age ranges with IDs (you might want to fetch these from API)
  final List<Map<String, dynamic>> _ageRanges = [
    {'id': 1, 'label': '0-6 Months', 'min': 0, 'max': 6},
    {'id': 2, 'label': '6-12 Months', 'min': 6, 'max': 12},
    {'id': 3, 'label': '1-3 Years', 'min': 12, 'max': 36},
    {'id': 4, 'label': '3-5 Years', 'min': 36, 'max': 60},
    {'id': 5, 'label': '5+ Years', 'min': 60, 'max': 120},
  ];

  // Sizes with IDs (you might want to fetch these from API)
  final List<Map<String, dynamic>> _standardSizes = [
    {'id': 1, 'label': 'S', },
    {'id': 2, 'label': 'M', },
    {'id': 3, 'label': 'L', },
    {'id': 4, 'label': 'XL', },
    {'id': 0, 'label': 'Custom', },
  ];

  // Combined sizes including custom option
  late List<Map<String, dynamic>> _sizes;

  @override
  void initState() {
    super.initState();
    // Initialize sizes with standard sizes (already includes custom option)
    _sizes = _standardSizes;
    _initializeFields();
  }

  // Helper function to extract numbers from custom size string
  String _extractNumbersFromString(String input) {
    // Use regex to extract only numbers (including decimals)
    final RegExp numberRegex = RegExp(r'\d+\.?\d*');
    final match = numberRegex.firstMatch(input);
    return match?.group(0) ?? '';
  }

  void _initializeFields() {
    // Debug: Print product data to understand the format
    print('Product ageRange: "${widget.product.ageRange}"');
    print('Product size: "${widget.product.size}"');
    print('Available age ranges: ${_ageRanges.map((e) => e['label']).toList()}');
    print('Available sizes: ${_sizes.map((e) => e['label']).toList()}');
    
    // Pre-fill the form with existing product data
    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();
    _stockController.text = widget.product.stock.toString();
    
    // Set age range - find matching age range
    try {
      final ageRangeMatch = _ageRanges.firstWhere(
        (range) => range['label'] == widget.product.ageRange,
        orElse: () => {},
      );
      if (ageRangeMatch.isNotEmpty) {
        _selectedAgeRange = ageRangeMatch['label'];
        _selectedAgeRangeId = ageRangeMatch['id'];
        print('Age range matched: $_selectedAgeRange');
      } else {
        _selectedAgeRange = null;
        _selectedAgeRangeId = null;
        print('Age range not found in list, setting to null');
      }
    } catch (e) {
      _selectedAgeRange = null;
      _selectedAgeRangeId = null;
      print('Error finding age range: $e');
    }
    
    // Set size - find matching size
    try {
      final sizeMatch = _sizes.firstWhere(
        (size) => size['label'] == widget.product.size,
        orElse: () => {},
      );
      if (sizeMatch.isNotEmpty) {
        _selectedSize = sizeMatch['label'];
        _selectedSizeId = sizeMatch['id'];
        if (widget.product.size == 'Custom') {
          _showCustomSize = true;
          // Extract only numbers from custom size
          _customSizeController.text = _extractNumbersFromString(widget.product.size);
        }
        print('Size matched: $_selectedSize');
      } else {
        // If size is not in predefined list, treat as custom
        _selectedSize = 'Custom';
        _selectedSizeId = 0; // Custom ID is 0
        _showCustomSize = true;
        // Extract only numbers from the size string
        _customSizeController.text = _extractNumbersFromString(widget.product.size);
        print('Size not found in list, treating as custom: ${widget.product.size}');
      }
    } catch (e) {
      _selectedSize = 'Custom';
      _selectedSizeId = 0; // Custom ID is 0
      _showCustomSize = true;
      // Extract only numbers from the size string
      _customSizeController.text = _extractNumbersFromString(widget.product.size);
      print('Error finding size: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _customSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 48,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Edit Product',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update product information',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product Name
                  _buildSectionTitle('Product Name'),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter product name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.shopping_bag),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Product Description
                  _buildSectionTitle('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter product description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product description';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Price and Stock Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Price (Rp)'),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Stock'),
                            TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.inventory),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter stock';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'Please enter valid stock';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Age Range Dropdown
                  _buildSectionTitle('Age Range'),
                  DropdownButtonFormField<String>(
                    value: _selectedAgeRange,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.child_care),
                    ),
                    hint: const Text('Select age range'),
                    items: _ageRanges.map((ageRange) {
                      return DropdownMenuItem<String>(
                        value: ageRange['label'],
                        child: Text(ageRange['label']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAgeRange = newValue;
                        final selectedRange = _ageRanges.firstWhere(
                          (range) => range['label'] == newValue,
                        );
                        _selectedAgeRangeId = selectedRange['id'];
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select age range';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Size Dropdown
                  _buildSectionTitle('Size'),
                  DropdownButtonFormField<String>(
                    value: _selectedSize,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.straighten),
                    ),
                    hint: const Text('Select size'),
                    items: _sizes.map((size) {
                      return DropdownMenuItem<String>(
                        value: size['label'],
                        child: Text(size['label']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSize = newValue;
                        final selectedSize = _sizes.firstWhere(
                          (size) => size['label'] == newValue,
                        );
                        _selectedSizeId = selectedSize['id'];
                        _showCustomSize = newValue == 'Custom';
                        if (!_showCustomSize) {
                          _customSizeController.clear();
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select size';
                      }
                      return null;
                    },
                  ),

                  // Custom Size Field (only shown when Custom is selected)
                  if (_showCustomSize) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Custom Size'),
                    TextFormField(
                      controller: _customSizeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter custom size (numbers only)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      validator: (value) {
                        if (_showCustomSize && (value == null || value.isEmpty)) {
                          return 'Please enter custom size';
                        }
                        if (_showCustomSize && value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Product Image
                  _buildSectionTitle('Product Image'),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_selectedImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'New image selected',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else if (widget.product.image.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.product.image,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Current image (select new image to replace)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ] else ...[
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No image available',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('From Gallery'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Take Photo'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: productProvider.isLoading ? null : _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: productProvider.isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Updating Product...'),
                              ],
                            )
                          : const Text(
                              'Update Product',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: productProvider.isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for required dropdowns
    if (_selectedAgeRange == null || _selectedAgeRangeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an age range'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSize == null || _selectedSizeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    try {
      final result = await productProvider.updateProduct(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        ageRange: _selectedAgeRange!,
        ageRangeId: _selectedAgeRangeId!,
        size: _selectedSize!,
        sizeId: _selectedSizeId!,
        customSize: _customSizeController.text.trim(),
        imageFile: _selectedImage,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result['message'] ?? 'Product updated successfully!')),
                ],
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 3),
            ),
          );

          // Return to previous page with success result
          Navigator.pop(context, true);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result['message'] ?? 'Failed to update product')),
                ],
              ),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to update product: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
