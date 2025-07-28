import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../providers/product_provider.dart';

class CreateProductAdmin extends StatefulWidget {
  const CreateProductAdmin({super.key});

  @override
  State<CreateProductAdmin> createState() => _CreateProductAdminState();
}

class _CreateProductAdminState extends State<CreateProductAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _customSizeController = TextEditingController();
  
  String _selectedAgeRangeLabel = '0-6 Months';
  int _selectedAgeRangeId = 1; // Add this to store the ID
  int _minAge = 0;
  int _maxAge = 6;
  String _selectedSize = 'S';
  int _selectedSizeId = 1; // Add this to store the size ID
  bool _isCustomSize = false;
  File? _selectedImage;
  bool _isLoading = false;


  final List<Map<String, dynamic>> _ageRanges = [
    {'id': 1, 'label': '0-6 Months', 'min': 0, 'max': 6},
    {'id': 2, 'label': '6-12 Months', 'min': 6, 'max': 12},
    {'id': 3, 'label': '1-3 Years', 'min': 12, 'max': 36},
    {'id': 4, 'label': '3-5 Years', 'min': 36, 'max': 60},
    {'id': 5, 'label': '5+ Years', 'min': 60, 'max': 120},
  ];


    final List<Map<String, dynamic>> _standardSizes = [
    {'id': 1, 'label': 'S', },
    {'id': 2, 'label': 'M', },
    {'id': 3, 'label': 'L', },
    {'id': 4, 'label': 'XL', },
  ];



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
        title: const Text('Create New Product'),
        backgroundColor: Colors.blue[600],
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
                  // Header
                 
                  // Product Basic Information
                  _buildSectionCard(
                    'Basic Information',
                    Icons.info_outline,
                    [
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'Product Name',
                        hint: 'Enter product name',
                        icon: Icons.shopping_bag,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter product description',
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _priceController,
                              label: 'Price',
                              hint: '0',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Price is required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _stockController,
                              label: 'Stock',
                              hint: '0',
                              icon: Icons.inventory,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Stock is required';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'Enter a valid stock number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  
                  // Age Range Selection
                  _buildSectionCard(
                    'Age Range',
                    Icons.child_care,
                    [
                      DropdownButtonFormField<String>(
                        value: _selectedAgeRangeLabel,
                        decoration: InputDecoration(
                          labelText: 'Target Age Range',
                          prefixIcon: const Icon(Icons.child_care),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _ageRanges.map((ageRange) {
                          return DropdownMenuItem<String>(
                            value: ageRange['label'],
                            child: Text(ageRange['label']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAgeRangeLabel = value!;
                            final selectedRange = _ageRanges.firstWhere(
                              (range) => range['label'] == value,
                            );
                            _selectedAgeRangeId = selectedRange['id']; // Save the ID
                            _minAge = selectedRange['min'];
                            _maxAge = selectedRange['max'];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: TextFormField(
                      //         initialValue: _minAge.toString(),
                      //         decoration: InputDecoration(
                      //           labelText: 'Min Age (months)',
                      //           prefixIcon: const Icon(Icons.access_time),
                      //           border: OutlineInputBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           filled: true,
                      //           fillColor: Colors.grey[50],
                      //         ),
                      //         keyboardType: TextInputType.number,
                      //         onChanged: (value) {
                      //           _minAge = int.tryParse(value) ?? _minAge;
                      //         },
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     Expanded(
                      //       child: TextFormField(
                      //         initialValue: _maxAge.toString(),
                      //         decoration: InputDecoration(
                      //           labelText: 'Max Age (months)',
                      //           prefixIcon: const Icon(Icons.access_time_filled),
                      //           border: OutlineInputBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           filled: true,
                      //           fillColor: Colors.grey[50],
                      //         ),
                      //         keyboardType: TextInputType.number,
                      //         onChanged: (value) {
                      //           _maxAge = int.tryParse(value) ?? _maxAge;
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Size Selection
                  _buildSectionCard(
                    'Size',
                    Icons.straighten,
                    [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedSize,
                            decoration: InputDecoration(
                              labelText: 'Product Size',
                              prefixIcon: const Icon(Icons.straighten),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: [
                              ..._standardSizes.map((size) {
                                return DropdownMenuItem<String>(
                                  value: size['label'],
                                  child: Text(size['label']),
                                );
                              }),
                              const DropdownMenuItem<String>(
                                value: 'Custom',
                                child: Text('Custom Size'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSize = value!;
                                _isCustomSize = value == 'Custom';
                                
                                // Save the size ID if it's not custom
                                if (value != 'Custom') {
                                  final selectedSize = _standardSizes.firstWhere(
                                    (size) => size['label'] == value,
                                  );
                                  _selectedSizeId = selectedSize['id'];
                                } else {
                                  _selectedSizeId = 0; // Use 0 or null for custom
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a size';
                              }
                              return null;
                            },
                          ),
                          if (_isCustomSize) ...[
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              controller: _customSizeController,
                              label: 'Custom Size (cm)',
                              hint: 'Enter size in centimeters',
                              icon: Icons.straighten,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (_isCustomSize && (value == null || value.trim().isEmpty)) {
                                  return 'Custom size is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Image Upload
                  _buildSectionCard(
                    'Product Image',
                    Icons.image,
                    [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to upload image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'JPG, PNG files are allowed',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Image selected',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Remove'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isLoading || productProvider.isLoading) 
                          ? null 
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: (_isLoading || productProvider.isLoading)
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
                                Text('Creating Product...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_shopping_cart),
                                SizedBox(width: 8),
                                Text(
                                  'Create Product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error Display
                  if (productProvider.errorMessage != null)
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                productProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () => productProvider.clearError(),
                              child: const Text('Dismiss'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      
      final response = await productProvider.createProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        ageRange: _selectedAgeRangeLabel,
        ageRangeId: _selectedAgeRangeId,
        size: _selectedSize,
        sizeId: _selectedSizeId,
        customSize: _customSizeController.text.trim(),
        imageFile: _selectedImage,
      );

      if (mounted) {
        if (response['success'] == true) {
          // Show success message with the message from server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(response['message'] ?? 'Product created successfully!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Clear form
          _clearForm();
          
          // Navigate back with the created product
          Navigator.of(context).pop(response['product']);
        } else {
          // Show error message from server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(response['message'] ?? 'Failed to create product'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
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
                Expanded(
                  child: Text('Failed to create product: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _customSizeController.clear();
    setState(() {
      _selectedAgeRangeLabel = '0-6 Months';
      _selectedAgeRangeId = 1;
      _minAge = 0;
      _maxAge = 6;
      _selectedSize = 'S';
      _selectedSizeId = 1;
      _isCustomSize = false;
      _selectedImage = null;
    });
  }
}
