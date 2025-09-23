/// @Branch: Enhanced Create Marketplace Screen
///
/// Intelligent product creation with dynamic fields based on category
/// Features: Smart validation, duplicate prevention, enhanced UI, review system
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/marketplace_item.dart' as marketplace_models;
import '../../../core/models/product_category.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/utils/image_upload_service.dart';
import '../../../core/widgets/platform_image.dart';

class EnhancedCreateMarketplaceScreen extends StatefulWidget {
  final marketplace_models.MarketplaceItem? item;

  const EnhancedCreateMarketplaceScreen({super.key, this.item});

  @override
  State<EnhancedCreateMarketplaceScreen> createState() =>
      _EnhancedCreateMarketplaceScreenState();
}

class _EnhancedCreateMarketplaceScreenState
    extends State<EnhancedCreateMarketplaceScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  // Dynamic field controllers
  final Map<String, TextEditingController> _dynamicControllers = {};
  final Map<String, String> _dynamicValues = {};
  final Map<String, List<String>> _multiselectValues = {};

  bool _isSaving = false;
  bool _isEditing = false;
  double _uploadProgress = 0;
  String _uploadStatus = '';

  String _selectedCategory = 'electronics';
  String _selectedSubcategory = '';
  String _selectedCondition = 'good';
  List<String> _uploadedImageUrls = [];
  List<String> _tags = [];
  bool _isNegotiable = false;
  bool _isFeatured = false;

  ProductCategory? _currentCategory;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCategory();
    _initializeDynamicFields();
    _isEditing = widget.item != null;
    if (_isEditing) {
      _populateFields();
    }
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      // Check if Firebase Storage is accessible
      final hasAccess = await ImageUploadService.checkBucketAccess(
        'product_images',
      );
      if (!hasAccess) {
        print(
          'Warning: Firebase Storage access limited for products. Upload may fail.',
        );
        // Don't show error to user unless upload actually fails
      } else {
        print('Firebase Storage ready for product images');
      }
    } catch (e) {
      print('Firebase connection check error: $e');
      // Don't show error to user - let them try uploading
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    for (var controller in _dynamicControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeCategory() {
    _currentCategory = ProductCategory.getCategoryById(_selectedCategory);
    if (_currentCategory != null &&
        _currentCategory!.subcategories.isNotEmpty) {
      _selectedSubcategory = _currentCategory!.subcategories.first;
    }
  }

  void _initializeDynamicFields() {
    if (_currentCategory != null) {
      for (final field in _currentCategory!.fields) {
        _dynamicControllers[field.id] = TextEditingController();
        _dynamicValues[field.id] = '';
        if (field.type == FieldType.multiselect) {
          _multiselectValues[field.id] = [];
        }
      }
    }
  }

  void _populateFields() {
    if (widget.item == null) return;

    final item = widget.item!;
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    _priceController.text = item.price.toString();
    _locationController.text = item.location ?? '';
    _selectedCategory = item.category;
    _selectedCondition = item.condition;
    _isNegotiable = item.isNegotiable;
    _isFeatured = item.isFeatured;
    _tags = List<String>.from(item.tags);
    _uploadedImageUrls = List<String>.from(item.images);

    _initializeCategory();
    _initializeDynamicFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Create Product'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySelector(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildBasicInfo(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDynamicFields(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildImageUpload(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAdditionalOptions(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ProductCategory.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'electronics';
                  _initializeCategory();
                  _initializeDynamicFields();
                });
              },
            ),
            if (_currentCategory != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _currentCategory!.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
            if (_currentCategory != null &&
                _currentCategory!.subcategories.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: _selectedSubcategory,
                decoration: const InputDecoration(
                  labelText: 'Subcategory',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subdirectory_arrow_right),
                ),
                items: _currentCategory!.subcategories.map((subcategory) {
                  return DropdownMenuItem<String>(
                    value: subcategory,
                    child: Text(subcategory.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubcategory = value ?? '';
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Product Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
                hintText: 'Enter a descriptive title for your product',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a product title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Describe your product in detail',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                if (value.trim().length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: '0.00',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      final price = double.tryParse(value.trim());
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      if (_currentCategory != null) {
                        final minPrice =
                            _currentCategory!.validationRules['minPrice']
                                as double?;
                        final maxPrice =
                            _currentCategory!.validationRules['maxPrice']
                                as double?;
                        if (minPrice != null && price < minPrice) {
                          return 'Price must be at least \$${minPrice.toStringAsFixed(0)}';
                        }
                        if (maxPrice != null && price > maxPrice) {
                          return 'Price must not exceed \$${maxPrice.toStringAsFixed(0)}';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'e.g., Harare, Zimbabwe',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (_currentCategory == null || _currentCategory!.fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_currentCategory!.name} Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._currentCategory!.fields.map(
              (field) => _buildDynamicField(field),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicField(ProductField field) {
    switch (field.type) {
      case FieldType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: TextFormField(
            controller: _dynamicControllers[field.id],
            decoration: InputDecoration(
              labelText: field.name,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.text_fields),
              hintText: field.placeholder,
            ),
            validator: field.required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '${field.name} is required';
                    }
                    return null;
                  }
                : null,
            onChanged: (value) {
              _dynamicValues[field.id] = value;
            },
          ),
        );

      case FieldType.number:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: TextFormField(
            controller: _dynamicControllers[field.id],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: field.name,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.numbers),
              hintText: field.placeholder,
            ),
            validator: field.required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '${field.name} is required';
                    }
                    final number = double.tryParse(value.trim());
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  }
                : null,
            onChanged: (value) {
              _dynamicValues[field.id] = value;
            },
          ),
        );

      case FieldType.select:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: DropdownButtonFormField<String>(
            value: _dynamicValues[field.id]?.isNotEmpty == true
                ? _dynamicValues[field.id]
                : null,
            decoration: InputDecoration(
              labelText: field.name,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.arrow_drop_down),
            ),
            items: field.options?.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _dynamicValues[field.id] = value ?? '';
              });
            },
            validator: field.required
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select ${field.name.toLowerCase()}';
                    }
                    return null;
                  }
                : null,
          ),
        );

      case FieldType.multiselect:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    field.options?.map((option) {
                      final isSelected =
                          _multiselectValues[field.id]?.contains(option) ??
                          false;
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _multiselectValues[field.id]?.add(option);
                            } else {
                              _multiselectValues[field.id]?.remove(option);
                            }
                          });
                        },
                      );
                    }).toList() ??
                    [],
              ),
            ],
          ),
        );

      case FieldType.textarea:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: TextFormField(
            controller: _dynamicControllers[field.id],
            maxLines: 3,
            decoration: InputDecoration(
              labelText: field.name,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.notes),
              hintText: field.placeholder,
            ),
            validator: field.required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '${field.name} is required';
                    }
                    return null;
                  }
                : null,
            onChanged: (value) {
              _dynamicValues[field.id] = value;
            },
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageUpload() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Images',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload clear photos of your product. ${_currentCategory?.validationRules['minImages'] ?? 1} image(s) required.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Image Requirements:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Maximum size: 2MB per image\n• Supported formats: JPG, PNG, GIF, WebP\n• Recommended resolution: 1920x1080 or lower',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_uploadedImageUrls.isNotEmpty)
              _buildImageGrid()
            else
              _buildImageUploadButton(),
            if (_uploadStatus.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(value: _uploadProgress / 100),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _uploadStatus,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (_uploadProgress > 0 && _uploadProgress < 100)
                    Text(
                      '${_uploadProgress.toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _uploadedImageUrls.length + 1,
      itemBuilder: (context, index) {
        if (index == _uploadedImageUrls.length) {
          return _buildAddImageButton();
        }
        return _buildImageItem(_uploadedImageUrls[index], index);
      },
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PlatformImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    final maxImages =
        _currentCategory?.validationRules['maxImages'] as int? ?? 10;
    final canAddMore = _uploadedImageUrls.length < maxImages;

    return GestureDetector(
      onTap: canAddMore ? _pickImages : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canAddMore ? Colors.grey[300]! : Colors.grey[200]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: canAddMore ? Colors.grey : Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Text(
              canAddMore ? 'Add Image' : 'Max reached',
              style: TextStyle(
                fontSize: 12,
                color: canAddMore ? Colors.grey : Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Multiple Images'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: _pickSingleImage,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Select Single Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Options',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              title: const Text('Price is negotiable'),
              subtitle: const Text('Buyers can make offers'),
              value: _isNegotiable,
              onChanged: (value) {
                setState(() {
                  _isNegotiable = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Featured listing'),
              subtitle: const Text('Make this product stand out'),
              value: _isFeatured,
              onChanged: (value) {
                setState(() {
                  _isFeatured = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEditing ? 'Update Product' : 'Create Product',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to upload images')),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) return;

      // Validate images before upload
      setState(() {
        _uploadStatus = 'Validating images...';
        _uploadProgress = 0;
      });

      final List<XFile> validImages = [];
      final List<String> invalidReasons = [];

      for (int i = 0; i < images.length; i++) {
        try {
          final isValid = await ImageUploadService.validateImage(images[i]);
          if (isValid) {
            validImages.add(images[i]);
          } else {
            // Try to determine why it's invalid
            final bytes = await images[i].readAsBytes();
            String reason = 'Unknown error';

            if (bytes.length > 4 * 1024 * 1024) {
              // 4MB
              reason =
                  'File too large (${(bytes.length / (1024 * 1024)).toStringAsFixed(1)}MB)';
            } else {
              reason = 'Invalid image format or corrupted file';
            }

            invalidReasons.add('Image ${i + 1}: $reason');
          }
        } catch (e) {
          print('Error validating image ${i + 1}: $e');
          invalidReasons.add('Image ${i + 1}: Validation error');
        }
      }

      // Show detailed feedback for invalid images
      if (invalidReasons.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Some images were rejected:'),
                ...invalidReasons.map((reason) => Text('• $reason')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      if (validImages.isEmpty) {
        setState(() {
          _uploadStatus = '';
          _uploadProgress = 0;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid images to upload'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _uploadStatus = 'Uploading ${validImages.length} image(s)...';
        _uploadProgress = 0;
      });

      try {
        final uploadedUrls = await ImageUploadService.uploadImages(
          images: validImages,
          userId: user.id,
          bucketType: 'products',
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _uploadProgress = progress;
              });
            }
          },
        );

        if (mounted) {
          setState(() {
            _uploadedImageUrls.addAll(uploadedUrls);
            _uploadStatus = '';
            _uploadProgress = 0;
          });

          if (uploadedUrls.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to upload images. Please check your internet connection and try again.',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          } else if (uploadedUrls.length < validImages.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${uploadedUrls.length}/${validImages.length} images uploaded successfully',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${uploadedUrls.length} image(s) uploaded successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (uploadError) {
        if (mounted) {
          setState(() {
            _uploadStatus = '';
            _uploadProgress = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${uploadError.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        print('Upload error: $uploadError');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadStatus = '';
          _uploadProgress = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting images: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('Image picker error: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImageUrls.removeAt(index);
    });
  }

  Future<void> _pickSingleImage() async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Please sign in to upload images')),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _uploadStatus = 'Uploading image...';
        _uploadProgress = 0;
      });

      try {
        final isValid = await ImageUploadService.validateImage(image);
        if (!isValid) {
          if (mounted) {
            setState(() {
              _uploadStatus = '';
              _uploadProgress = 0;
            });

            // Try to determine why it's invalid
            String reason = 'Unknown error';
            try {
              final bytes = await image.readAsBytes();
              if (bytes.length > 4 * 1024 * 1024) {
                // 4MB
                reason =
                    'File too large (${(bytes.length / (1024 * 1024)).toStringAsFixed(1)}MB). Maximum size is 2MB.';
              } else {
                reason =
                    'Invalid image format or corrupted file. Please try a different image.';
              }
            } catch (e) {
              reason = 'Could not read image file.';
            }

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Image validation failed: $reason'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        final uploadedUrl = await ImageUploadService.uploadSingleImage(
          image: image,
          userId: user.id,
          bucketType: 'products',
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _uploadProgress = progress;
              });
            }
          },
        );

        if (mounted) {
          setState(() {
            _uploadStatus = '';
            _uploadProgress = 0;
          });

          if (uploadedUrl != null) {
            setState(() {
              _uploadedImageUrls.add(uploadedUrl);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (uploadError) {
        if (mounted) {
          setState(() {
            _uploadStatus = '';
            _uploadProgress = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${uploadError.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Single image upload error: $uploadError');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadStatus = '';
          _uploadProgress = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Single image picker error: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create a product')),
      );
      return;
    }

    // Validate images
    final minImages =
        _currentCategory?.validationRules['minImages'] as int? ?? 1;
    if (_uploadedImageUrls.length < minImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload at least $minImages image(s)')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final price = double.parse(_priceController.text.trim());

      // Prepare dynamic fields data
      final Map<String, dynamic> dynamicFields = {};
      for (final field in _currentCategory?.fields ?? []) {
        if (field.type == FieldType.multiselect) {
          final List<String>? multiselectValue = _multiselectValues[field.id];
          dynamicFields[field.id] = multiselectValue ?? <String>[];
        } else {
          final String value = (_dynamicValues[field.id] as String?) ?? '';
          dynamicFields[field.id] = value;
        }
      }

      final productData = {
        if (_isEditing) 'id': widget.item!.id,
        'userId': user.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'currency': 'USD',
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'condition': _selectedCondition,
        'location': _locationController.text.trim(),
        'university': user.university ?? 'Not specified',
        'images': _uploadedImageUrls,
        'isAvailable': true,
        'isFeatured': _isFeatured,
        'isNegotiable': _isNegotiable,
        'tags': _tags,
        'dynamicFields': dynamicFields,
      };

      Map<String, dynamic>? result;
      if (_isEditing) {
        result = await FirebaseRepository.updateProduct(
          productData['id']! as String,
          productData,
        );
      } else {
        result = await FirebaseRepository.createProduct(productData);
      }

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Product updated successfully!'
                    : 'Product created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save product'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.item == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        final success = await FirebaseRepository.deleteProduct(widget.item!.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

// Export alias for backward compatibility
typedef CreateMarketplaceScreen = EnhancedCreateMarketplaceScreen;
