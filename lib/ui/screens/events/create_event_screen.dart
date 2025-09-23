/// @Branch: Create Event Screen Implementation
///
/// Event creation and editing with date/time selection and ticket management
/// Includes form validation and event management features
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/services/auth_service.dart';

class CreateEventScreen extends StatefulWidget {
  // For editing existing events

  const CreateEventScreen({super.key, this.event});
  final Map<String, dynamic>? event;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _organizerEmailController = TextEditingController();
  final _organizerPhoneController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isSaving = false;
  bool _isEditing = false;

  String _selectedCategory = 'academic';
  String _selectedType = 'free';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay(hour: 22, minute: 0);
  List<String> _selectedImages = [];
  List<String> _selectedTags = [];
  List<String> _selectedRequirements = [];
  bool _requiresApproval = false;
  bool _isFeatured = false;

  final List<String> _categories = [
    'academic',
    'social',
    'sports',
    'cultural',
    'workshop',
    'conference',
    'party',
    'other',
  ];

  final List<String> _types = ['free', 'paid'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.event != null;
    _initializeAnimations();
    _loadEventData();
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
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
    _locationController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _organizerEmailController.dispose();
    _organizerPhoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _loadEventData() {
    if (_isEditing && widget.event != null) {
      final event = widget.event!;
      _titleController.text = (event['title'] as String?) ?? '';
      _descriptionController.text = (event['description'] as String?) ?? '';
      _locationController.text = (event['location'] as String?) ?? '';
      _addressController.text = (event['address'] as String?) ?? '';
      _priceController.text = (event['price'] as num?)?.toString() ?? '0';
      _capacityController.text =
          (event['maxAttendees'] as num?)?.toString() ?? '';
      _organizerEmailController.text =
          (event['organizerEmail'] as String?) ?? '';
      _organizerPhoneController.text =
          (event['organizerPhone'] as String?) ?? '';
      _latitudeController.text = (event['latitude'] as num?)?.toString() ?? '';
      _longitudeController.text =
          (event['longitude'] as num?)?.toString() ?? '';
      _selectedCategory = (event['type'] as String?) ?? 'academic';
      _selectedCurrency = (event['currency'] as String?) ?? 'USD';
      _selectedType = (event['isFree'] as bool?) ?? true ? 'free' : 'paid';
      _requiresApproval = (event['requiresApproval'] as bool?) ?? false;
      _isFeatured = (event['isFeatured'] as bool?) ?? false;
      _selectedImages = List<String>.from((event['imageUrls'] as List?) ?? []);
      _selectedTags = List<String>.from((event['tags'] as List?) ?? []);
      _selectedRequirements = List<String>.from(
        (event['requirements'] as List?) ?? [],
      );

      if (event['startDate'] != null) {
        _selectedDate = DateTime.parse(event['startDate'] as String);
      }
      if (event['endDate'] != null) {
        _selectedEndDate = DateTime.parse(event['endDate'] as String);
      }
      if (event['startTime'] != null) {
        final timeParts = (event['startTime'] as String).split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    } else {
      // Set default values for new events
      final userEmail = AuthService.currentUserEmail ?? '';
      _organizerEmailController.text = userEmail;
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create events')),
        );
        return;
      }

      final eventData = {
        'id': _isEditing ? widget.event!['id'] : const Uuid().v4(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
        'type': _selectedCategory,
        'isFree': _selectedType == 'free',
        'price': _selectedType == 'paid'
            ? double.tryParse(_priceController.text.trim())
            : 0.0,
        'currency': _selectedCurrency,
        'startDate': _selectedDate.toIso8601String(),
        'endDate': _selectedEndDate.toIso8601String(),
        'maxAttendees': int.tryParse(_capacityController.text.trim()) ?? 0,
        'currentAttendees': 0,
        'organizerId': user.id,
        'organizerName': user.fullName.isNotEmpty ? user.fullName : user.email,
        'organizerEmail': _organizerEmailController.text.trim(),
        'organizerPhone': _organizerPhoneController.text.trim(),
        'latitude': _latitudeController.text.trim().isNotEmpty
            ? double.tryParse(_latitudeController.text.trim())
            : null,
        'longitude': _longitudeController.text.trim().isNotEmpty
            ? double.tryParse(_longitudeController.text.trim())
            : null,
        'imageUrls': _selectedImages,
        'tags': _selectedTags,
        'requirements': _selectedRequirements,
        'requiresApproval': _requiresApproval,
        'isFeatured': _isFeatured,
        'status': 'active',
        'viewCount': 0,
        'favoriteCount': 0,
        'tickets': <Map<String, dynamic>>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await FirebaseRepository.updateEvent(
          eventData['id'] as String,
          eventData,
        );
      } else {
        await FirebaseRepository.createEvent(eventData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Event updated successfully!'
                  : 'Event created successfully!',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving event: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedEndDate = date;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );

    if (time != null) {
      setState(() {
        _selectedEndTime = time;
      });
    }
  }

  Future<void> _selectImages() async {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker not implemented yet')),
    );
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
      _isEditing ? 'Edit Event' : 'Create Event',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isSaving ? null : _saveEvent,
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
    builder: (context, child) {
      return FadeTransition(
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

                // Date and Time
                _buildDateTimeSection(theme),

                const SizedBox(height: AppSpacing.xl),

                // Category and Type
                _buildCategorySection(theme),

                const SizedBox(height: AppSpacing.xl),

                // Price and Capacity
                _buildPriceCapacitySection(theme),

                const SizedBox(height: AppSpacing.xl),

                // Location Details
                _buildLocationSection(theme),

                const SizedBox(height: AppSpacing.xl),

                // Organizer Contact
                _buildOrganizerSection(theme),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildImagesSection(ThemeData theme) => AnimatedBuilder(
    animation: _slideAnimation,
    builder: (context, child) {
      return SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo_camera,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Event Photos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                if (_selectedImages.isEmpty)
                  _buildImagePlaceholder(theme)
                else
                  _buildImageGrid(theme),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _selectImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(
                      _selectedImages.isEmpty
                          ? 'Add Photos'
                          : 'Add More Photos',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildImagePlaceholder(ThemeData theme) => Container(
    height: 200,
    width: double.infinity,
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.3),
        style: BorderStyle.solid,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add photos to showcase your event',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildImageGrid(ThemeData theme) => GridView.builder(
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

      return _buildImageItem(theme, _selectedImages[index], index);
    },
  );

  Widget _buildAddImageButton(ThemeData theme) => GestureDetector(
    onTap: _selectImages,
    child: Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: theme.colorScheme.outline),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildImageItem(ThemeData theme, String imageUrl, int index) =>
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
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
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBasicInfoSection(ThemeData theme) =>
      _buildSection(theme, 'Event Information', Icons.event, [
        _buildTextField(
          controller: _titleController,
          label: 'Event Title',
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
          hintText: 'Describe your event in detail...',
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
        _buildTextField(
          controller: _locationController,
          label: 'Location',
          icon: Icons.location_on,
          hintText: 'e.g., University Campus, Room 101',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Location is required';
            }
            return null;
          },
        ),
      ]);

  Widget _buildDateTimeSection(ThemeData theme) =>
      _buildSection(theme, 'Date & Time', Icons.schedule, [
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                theme,
                'Start Date',
                _selectedDate,
                _selectDate,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTimeField(
                theme,
                'Start Time',
                _selectedTime,
                _selectTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                theme,
                'End Date',
                _selectedEndDate,
                _selectEndDate,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTimeField(
                theme,
                'End Time',
                _selectedEndTime,
                _selectEndTime,
              ),
            ),
          ],
        ),
      ]);

  Widget _buildDateField(
    ThemeData theme,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildTimeField(
    ThemeData theme,
    String label,
    TimeOfDay time,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: theme.colorScheme.outline, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(time.format(context), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCategorySection(ThemeData theme) =>
      _buildSection(theme, 'Category & Type', Icons.category, [
        _buildDropdownField(
          value: _selectedCategory,
          label: 'Category',
          icon: Icons.category,
          items: _categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDropdownField(
          value: _selectedType,
          label: 'Type',
          icon: Icons.monetization_on,
          items: _types
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
      ]);

  Widget _buildPriceCapacitySection(ThemeData theme) =>
      _buildSection(theme, 'Price & Capacity', Icons.people, [
        if (_selectedType == 'paid') ...[
          _buildTextField(
            controller: _priceController,
            label: 'Price',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Price is required for paid events';
              }
              if (double.tryParse(value.trim()) == null) {
                return 'Please enter a valid price';
              }
              if (double.parse(value.trim()) <= 0) {
                return 'Price must be greater than 0';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildTextField(
          controller: _capacityController,
          label: 'Capacity',
          icon: Icons.people,
          keyboardType: TextInputType.number,
          hintText: 'Maximum number of attendees',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Capacity is required';
            }
            if (int.tryParse(value.trim()) == null) {
              return 'Please enter a valid number';
            }
            if (int.parse(value.trim()) <= 0) {
              return 'Capacity must be greater than 0';
            }
            return null;
          },
        ),
      ]);

  Widget _buildLocationSection(ThemeData theme) =>
      _buildSection(theme, 'Location Details', Icons.location_on, [
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.home,
          hintText: 'Full address of the event location',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _latitudeController,
                label: 'Latitude (Optional)',
                icon: Icons.my_location,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                hintText: 'e.g., -17.8252',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final lat = double.tryParse(value.trim());
                    if (lat == null) {
                      return 'Please enter a valid latitude';
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
                label: 'Longitude (Optional)',
                icon: Icons.my_location,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                hintText: 'e.g., 31.0335',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final lng = double.tryParse(value.trim());
                    if (lng == null) {
                      return 'Please enter a valid longitude';
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
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
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

  Widget _buildOrganizerSection(ThemeData theme) =>
      _buildSection(theme, 'Organizer Contact', Icons.person, [
        _buildTextField(
          controller: _organizerEmailController,
          label: 'Email Address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          hintText: 'your.email@example.com',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _organizerPhoneController,
          label: 'Phone Number (Optional)',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          hintText: '+1 (555) 123-4567',
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (!RegExp(
                r'^[\+]?[1-9][\d]{0,15}$',
              ).hasMatch(value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                return 'Please enter a valid phone number';
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
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
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
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      items: items,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // TODO: Implement actual location service
      // For now, show a placeholder dialog
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Get Current Location'),
            content: const Text(
              'Location services integration coming soon!\n\n'
              'For now, you can manually enter the coordinates or use an external map app to get the precise location.',
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
      print('Error getting current location: $e');
    }
  }

  Future<void> _openMapPicker() async {
    try {
      // TODO: Implement map picker
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Location on Map'),
            content: const Text(
              'Map picker integration coming soon!\n\n'
              'For now, you can manually enter the address and coordinates.',
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
      print('Error opening map picker: $e');
    }
  }
}
