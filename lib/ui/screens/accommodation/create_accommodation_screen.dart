/// @Branch: Create Accommodation Screen Implementation
///
/// Accommodation creation and editing with image upload and property details
/// Includes form validation and accommodation management features
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/utils/image_upload_service.dart';
import '../../../core/widgets/platform_image.dart';

class CreateAccommodationScreen extends StatefulWidget {
  // For editing existing accommodations

  const CreateAccommodationScreen({super.key, this.accommodation});
  final Map<String, dynamic>? accommodation;

  @override
  State<CreateAccommodationScreen> createState() =>
      _CreateAccommodationScreenState();
}

class _CreateAccommodationScreenState extends State<CreateAccommodationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _hostEmailController = TextEditingController();
  final _hostPhoneController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isSaving = false;
  bool _isEditing = false;
  bool _isUploadingImages = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  String _selectedPropertyType = 'apartment';
  String _selectedRoomType = 'single';
  String _selectedCurrency = 'USD';
  String _selectedAreaUnit = 'sqft';
  String _selectedPricePeriod = 'month';
  List<String> _selectedImages = [];
  List<String> _selectedAmenities = [];
  List<String> _selectedRules = [];

  final List<String> _propertyTypes = [
    'apartment',
    'house',
    'room',
    'dormitory',
    'studio',
    'shared_room',
    'full_room',
    '2_room_share',
    '3_room_share',
    'other',
  ];

  final List<String> _roomTypes = [
    'single',
    'double',
    'shared',
    'studio',
    'full_room',
    '2_room_share',
    '3_room_share',
  ];

  final List<String> _currencies = ['USD', 'ZWL', 'EUR', 'GBP'];
  final List<String> _areaUnits = ['sqft', 'sqm'];
  final List<String> _pricePeriods = ['month', 'week', 'day', 'year'];

  final List<String> _availableAmenities = [
    'WiFi',
    'Air Conditioning',
    'Heating',
    'Kitchen',
    'Washing Machine',
    'Dryer',
    'Parking',
    'Gym',
    'Pool',
    'Garden',
    'Balcony',
    'Furnished',
    'Pet Friendly',
    'Smoking Allowed',
    'Near Campus',
    'Public Transport',
    'Security',
    'Cleaning Service',
  ];

  final List<String> _availableRules = [
    'No Smoking',
    'No Pets',
    'No Parties',
    'No Loud Music',
    'No Overnight Guests',
    'Keep Common Areas Clean',
    'Respect Quiet Hours',
    'No Cooking After 10 PM',
  ];

  // Toast helper methods with fallback to SnackBar
  void _showToast(String message, {bool isError = false}) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: isError ? Colors.red : Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // Fallback to SnackBar if toast fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSuccessToast(String message) {
    _showToast(message, isError: false);
  }

  void _showErrorToast(String message) {
    _showToast(message, isError: true);
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.accommodation != null;
    _initializeAnimations();
    _loadAccommodationData();
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      // Check if Firebase Storage is accessible
      final hasAccess = await ImageUploadService.checkBucketAccess(
        'accommodation_images',
      );
      if (!hasAccess) {
        print(
          'Warning: Firebase Storage access limited for accommodations. Upload may fail.',
        );
        // Don't show error to user unless upload actually fails
      } else {
        print('Firebase Storage ready for accommodation images');
      }
    } catch (e) {
      print('Firebase connection check error: $e');
      // Don't show error to user - let them try uploading
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _hostEmailController.dispose();
    _hostPhoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _loadAccommodationData() {
    if (_isEditing && widget.accommodation != null) {
      final accommodation = widget.accommodation!;
      _titleController.text = (accommodation['title'] as String?) ?? '';
      _descriptionController.text =
          (accommodation['description'] as String?) ?? '';
      _priceController.text =
          (accommodation['price_per_month'] as num?)?.toString() ?? '';
      _addressController.text = (accommodation['address'] as String?) ?? '';
      _bedroomsController.text =
          (accommodation['bedrooms'] as num?)?.toString() ?? '1';
      _bathroomsController.text =
          (accommodation['bathrooms'] as num?)?.toString() ?? '1';
      _areaController.text = (accommodation['area'] as num?)?.toString() ?? '';
      _selectedPropertyType =
          (accommodation['property_type'] as String?) ?? 'apartment';
      _selectedRoomType = (accommodation['room_type'] as String?) ?? 'single';
      _selectedCurrency = (accommodation['currency'] as String?) ?? 'USD';
      _selectedAreaUnit = (accommodation['area_unit'] as String?) ?? 'sqft';
      _selectedPricePeriod =
          (accommodation['pricePeriod'] as String?) ?? 'month';
      _hostEmailController.text = (accommodation['hostEmail'] as String?) ?? '';
      _hostPhoneController.text = (accommodation['hostPhone'] as String?) ?? '';
      _latitudeController.text =
          (accommodation['latitude'] as num?)?.toString() ?? '';
      _longitudeController.text =
          (accommodation['longitude'] as num?)?.toString() ?? '';
      _selectedImages = List<String>.from(
        (accommodation['images'] as List?) ?? [],
      );
      _selectedAmenities = List<String>.from(
        (accommodation['amenities'] as List?) ?? [],
      );
      _selectedRules = List<String>.from(
        (accommodation['rules'] as List?) ?? [],
      );
    }
  }

  Future<void> _saveAccommodation() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate images
    if (_selectedImages.isEmpty) {
      _showErrorToast('Please upload at least one photo of your property');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        _showErrorToast('Please sign in to create accommodations');
        return;
      }

      final accommodationData = {
        if (_isEditing) 'id': widget.accommodation!['id'],
        'userId': user.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'pricePerMonth': double.parse(_priceController.text.trim()),
        'currency': _selectedCurrency,
        'pricePeriod': _selectedPricePeriod,
        'propertyType': _selectedPropertyType,
        'type': _selectedPropertyType,
        'roomType': _selectedRoomType,
        'bedrooms': int.tryParse(_bedroomsController.text.trim()) ?? 1,
        'bathrooms': int.tryParse(_bathroomsController.text.trim()) ?? 1,
        'area': _areaController.text.trim().isNotEmpty
            ? double.tryParse(_areaController.text.trim())
            : null,
        'areaUnit': _selectedAreaUnit,
        'address': _addressController.text.trim(),
        'latitude': _latitudeController.text.trim().isNotEmpty
            ? double.tryParse(_latitudeController.text.trim())
            : null,
        'longitude': _longitudeController.text.trim().isNotEmpty
            ? double.tryParse(_longitudeController.text.trim())
            : null,
        'hostId': user.id,
        'hostName': user.fullName.isNotEmpty ? user.fullName : user.email,
        'hostEmail': _hostEmailController.text.trim().isNotEmpty
            ? _hostEmailController.text.trim()
            : user.email,
        'hostPhone': _hostPhoneController.text.trim().isNotEmpty
            ? _hostPhoneController.text.trim()
            : null,
        'hostProfileImage': user.profileImageUrl,
        'images': _selectedImages,
        'imageUrls': _selectedImages,
        'amenities': _selectedAmenities,
        'rules': _selectedRules,
        'isAvailable': true,
        'isFeatured': false,
        'viewCount': 0,
        'favoriteCount': 0,
        'status': 'active',
        'university': user.university ?? 'Not specified',
        'createdAt': _isEditing ? null : DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      Map<String, dynamic>? result;
      if (_isEditing) {
        result = await FirebaseRepository.updateAccommodation(
          accommodationData['id'] as String,
          accommodationData,
        );
      } else {
        result = await FirebaseRepository.createAccommodation(
          accommodationData,
        );
      }

      if (result != null && mounted) {
        _showSuccessToast(
              _isEditing
                  ? 'Accommodation updated successfully!'
                  : 'Accommodation created successfully!',
        );
        context.pop();
      } else if (mounted) {
        _showErrorToast('Failed to save accommodation');
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) => AppBar(
    backgroundColor: theme.colorScheme.surface,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.pop(),
    ),
    title: Text(
      _isEditing ? 'Edit Accommodation' : 'List Property',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isSaving ? null : _saveAccommodation,
        child: _isSaving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Text(
                _isEditing ? 'Update' : 'Create',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ],
  );

  Widget _buildBody(ThemeData theme) => AnimatedBuilder(
    animation: _fadeAnimation,
    builder: (context, child) => FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Images Section
              _buildImagesSection(theme),

              const SizedBox(height: AppSpacing.xl),

              // Basic Information
              _buildBasicInfoSection(theme),

              const SizedBox(height: AppSpacing.xl),

              // Property Details
              _buildPropertyDetailsSection(theme),

              const SizedBox(height: AppSpacing.xl),

              // Amenities and Rules
              _buildAmenitiesSection(theme),

              const SizedBox(height: AppSpacing.xl),

              // Location
              _buildLocationSection(theme),

              const SizedBox(height: AppSpacing.xl),

              // Host Contact Information
              _buildHostContactSection(theme),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildImagesSection(
    ThemeData theme,
  ) => _buildSection(theme, 'Property Photos', Icons.photo_camera, [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo Requirements:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Maximum size: 2MB per image\n• Supported formats: JPG, PNG, GIF, WebP\n• Recommended: Multiple angles of the property',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
          ),
        ],
      ),
    ),
    const SizedBox(height: AppSpacing.md),
    if (_selectedImages.isNotEmpty) ...[
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return _buildAddImageButton(theme);
          }
          return _buildImageItem(_selectedImages[index], index, theme);
        },
      ),
      const SizedBox(height: AppSpacing.md),
    ] else
      _buildImageUploadButtons(theme),

    // Upload progress indicator
    if (_isUploadingImages) ...[
      const SizedBox(height: AppSpacing.md),
      Column(
        children: [
          LinearProgressIndicator(
            value: _uploadProgress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(_uploadStatus, style: theme.textTheme.bodySmall),
              ),
              if (_uploadProgress > 0 && _uploadProgress < 100)
                Text(
                  '${_uploadProgress.toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    ],
  ]);

  Widget _buildImageItem(String imageUrl, int index, ThemeData theme) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PlatformImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index);
              });
            },
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

  Widget _buildAddImageButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isSaving ? null : _pickImages,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isSaving ? Colors.grey[300]! : theme.colorScheme.primary,
            width: 2,
          ),
          color: _isSaving
              ? Colors.grey[50]
              : theme.colorScheme.primary.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: _isSaving ? Colors.grey[400] : theme.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add More',
              style: TextStyle(
                fontSize: 12,
                color: _isSaving ? Colors.grey[400] : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _pickImages,
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Multiple Photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : _pickSingleImage,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Select Single Photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) =>
      _buildSection(theme, 'Basic Information', Icons.info, [
        _buildTextField(
          controller: _titleController,
          label: 'Property Title',
          icon: Icons.title,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          icon: Icons.description,
          maxLines: 4,
          hintText: 'Describe your property in detail...',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid price';
                  }
                  if (double.parse(value.trim()) <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildDropdown(
                value: _selectedCurrency,
                items: _currencies,
                label: 'Currency',
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildDropdown(
                value: _selectedPricePeriod,
                items: _pricePeriods,
                label: 'Period',
                onChanged: (value) {
                  setState(() {
                    _selectedPricePeriod = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ]);

  Widget _buildPropertyDetailsSection(ThemeData theme) =>
      _buildSection(theme, 'Property Details', Icons.home, [
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: _selectedPropertyType,
                items: _propertyTypes,
                label: 'Property Type',
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyType = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildDropdown(
                value: _selectedRoomType,
                items: _roomTypes,
                label: 'Room Type',
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _bedroomsController,
                label: 'Bedrooms',
                icon: Icons.bed,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Number of bedrooms is required';
                  }
                  final bedrooms = int.tryParse(value.trim());
                  if (bedrooms == null || bedrooms < 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                controller: _bathroomsController,
                label: 'Bathrooms',
                icon: Icons.bathtub,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Number of bathrooms is required';
                  }
                  final bathrooms = double.tryParse(value.trim());
                  if (bathrooms == null || bathrooms < 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _areaController,
                label: 'Area',
                icon: Icons.square_foot,
                keyboardType: TextInputType.number,
                hintText: 'Optional',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildDropdown(
                value: _selectedAreaUnit,
                items: _areaUnits,
                label: 'Unit',
                onChanged: (value) {
                  setState(() {
                    _selectedAreaUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ]);

  Widget _buildAmenitiesSection(
    ThemeData theme,
  ) => _buildSection(theme, 'Amenities & Rules', Icons.star, [
    Text(
      'Select Amenities',
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    const SizedBox(height: AppSpacing.sm),
    Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _availableAmenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(amenity),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    ),
    const SizedBox(height: AppSpacing.lg),
    Text(
      'House Rules',
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    const SizedBox(height: AppSpacing.sm),
    Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _availableRules.map((rule) {
        final isSelected = _selectedRules.contains(rule);
        return FilterChip(
          label: Text(rule),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedRules.add(rule);
              } else {
                _selectedRules.remove(rule);
              }
            });
          },
          selectedColor: theme.colorScheme.secondary.withOpacity(0.2),
          checkmarkColor: theme.colorScheme.secondary,
        );
      }).toList(),
    ),
  ]);

  Widget _buildLocationSection(ThemeData theme) =>
      _buildSection(theme, 'Location', Icons.location_on, [
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on,
          hintText: 'Enter the full address of your property',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Coordinates (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add precise coordinates for better map integration',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _latitudeController,
                label: 'Latitude',
                icon: Icons.my_location,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                hintText: 'e.g., -17.8252',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final lat = double.tryParse(value.trim());
                    if (lat == null) {
                      return 'Enter a valid latitude';
                    }
                    if (lat < -90 || lat > 90) {
                      return 'Latitude must be between -90 and 90';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                controller: _longitudeController,
                label: 'Longitude',
                icon: Icons.my_location,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                hintText: 'e.g., 31.0335',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final lng = double.tryParse(value.trim());
                    if (lng == null) {
                      return 'Enter a valid longitude';
                    }
                    if (lng < -180 || lng > 180) {
                      return 'Longitude must be between -180 and 180';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Get Current Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openMapPicker,
                icon: const Icon(Icons.map),
                label: const Text('Select on Map'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ]);

  Widget _buildHostContactSection(ThemeData theme) =>
      _buildSection(theme, 'Host Contact Information', Icons.contact_phone, [
        Text(
          'Contact Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Provide your contact information for potential tenants',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _hostEmailController,
          label: 'Email Address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          hintText: 'your.email@example.com',
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Enter a valid email address';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _hostPhoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          hintText: '+1 (555) 123-4567',
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              final phoneRegex = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
              if (!phoneRegex.hasMatch(
                value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''),
              )) {
                return 'Enter a valid phone number';
              }
            }
            return null;
          },
        ),
      ]);

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    ),
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
  );

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    ),
    items: items
        .map(
          (item) => DropdownMenuItem(
            value: item,
            child: Text(_formatDisplayText(item)),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );

  String _formatDisplayText(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word,
        )
        .join(' ');
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (mounted) {
        _showToast('Getting your current location...', isError: false);
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showErrorToast(
            'Location services are disabled. Please enable them in settings.',
          );
        }
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showErrorToast('Location permissions are denied');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showErrorToast(
            'Location permissions are permanently denied. Please enable them in app settings.',
          );
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
        });
        _showSuccessToast('Location obtained successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Error getting location: ${e.toString()}');
      }
      print('Location error: $e');
    }
  }

  Future<void> _openMapPicker() async {
    try {
      if (mounted) {
        _showToast('Opening map picker...', isError: false);
      }

      // TODO: Implement map picker integration
      // For now, show a placeholder dialog
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Location on Map'),
            content: const Text(
              'Map picker integration coming soon!\n\n'
              'For now, you can manually enter the address and coordinates or use the "Get Current Location" button.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Error opening map picker: ${e.toString()}');
      }
      print('Map picker error: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        if (mounted) {
          _showErrorToast('Please sign in to upload images');
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) return;

      // Show upload progress
      setState(() {
        _isUploadingImages = true;
        _uploadProgress = 0.0;
        _uploadStatus = 'Validating images...';
      });

      try {
        // Validate images before upload
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
          _showErrorToast(
            'Some images were rejected: ${invalidReasons.join(', ')}',
          );
        }

        if (validImages.isEmpty) {
          if (mounted) {
            _showErrorToast('No valid images to upload');
          }
          return;
        }

        // Upload images to Firebase Storage
        setState(() {
          _uploadStatus = 'Uploading ${validImages.length} image(s)...';
          _uploadProgress = 0.0;
        });

        final uploadedUrls = await ImageUploadService.uploadAccommodationImages(
          images: validImages,
          userId: user.id,
          accommodationId: _isEditing
              ? widget.accommodation!['id'] as String?
              : null,
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
            _selectedImages.addAll(uploadedUrls);
          });

          if (uploadedUrls.isEmpty) {
            _showErrorToast(
                  'Failed to upload images. Please check your internet connection and try again.',
            );
          } else if (uploadedUrls.length < validImages.length) {
            _showToast(
                  '${uploadedUrls.length}/${validImages.length} images uploaded successfully',
              isError: false,
            );
          } else {
            _showSuccessToast(
                  '${uploadedUrls.length} image(s) uploaded successfully',
            );
          }
        }
      } catch (uploadError) {
        if (mounted) {
          _showErrorToast('Upload failed: ${uploadError.toString()}');
        }
        print('Upload error: $uploadError');
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Error selecting images: ${e.toString()}');
      }
      print('Image picker error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
          _uploadProgress = 0.0;
          _uploadStatus = '';
        });
      }
    }
  }

  Future<void> _pickSingleImage() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        if (mounted) {
          _showErrorToast('Please sign in to upload images');
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _isUploadingImages = true;
        _uploadProgress = 0.0;
        _uploadStatus = 'Uploading image...';
      });

      try {
        final isValid = await ImageUploadService.validateImage(image);
        if (!isValid) {
          if (mounted) {
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

            // ignore: use_build_context_synchronously
            _showErrorToast('Image validation failed: $reason');
          }
          return;
        }

        final uploadedUrl = await ImageUploadService.uploadSingleImage(
          image: image,
          userId: user.id,
          productId: _isEditing ? widget.accommodation!['id'] as String? : null,
          bucketType: 'accommodations',
        );

        if (mounted) {
          if (uploadedUrl != null) {
            setState(() {
              _selectedImages.add(uploadedUrl);
            });
            _showSuccessToast('Image uploaded successfully');
          } else {
            _showErrorToast('Failed to upload image. Please try again.');
          }
        }
      } catch (uploadError) {
        if (mounted) {
          _showErrorToast('Upload failed: ${uploadError.toString()}');
        }
        print('Single image upload error: $uploadError');
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Error selecting image: ${e.toString()}');
      }
      print('Single image picker error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
          _uploadProgress = 0.0;
          _uploadStatus = '';
        });
      }
    }
  }
}
