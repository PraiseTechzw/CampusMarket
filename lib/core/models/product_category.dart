/// @Branch: Product Category Model
///
/// Intelligent product category system with dynamic fields
/// Each category has specific fields and validation rules
library;

class ProductCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<ProductField> fields;
  final List<String> subcategories;
  final Map<String, dynamic> validationRules;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.fields,
    required this.subcategories,
    required this.validationRules,
  });

  static const List<ProductCategory> categories = [
    ProductCategory(
      id: 'electronics',
      name: 'Electronics',
      description: 'Phones, laptops, gadgets, and electronic devices',
      icon: '📱',
      subcategories: [
        'phones',
        'laptops',
        'tablets',
        'headphones',
        'cameras',
        'gaming',
        'other',
      ],
      fields: [
        ProductField(
          id: 'brand',
          name: 'Brand',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., Apple, Samsung, Dell',
        ),
        ProductField(
          id: 'model',
          name: 'Model',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., iPhone 14, MacBook Pro',
        ),
        ProductField(
          id: 'condition',
          name: 'Condition',
          type: FieldType.select,
          required: true,
          options: ['New', 'Like New', 'Good', 'Fair', 'Poor'],
        ),
        ProductField(
          id: 'warranty',
          name: 'Warranty',
          type: FieldType.select,
          required: false,
          options: ['Yes', 'No', 'Expired'],
        ),
        ProductField(
          id: 'accessories',
          name: 'Accessories Included',
          type: FieldType.multiselect,
          required: false,
          options: [
            'Charger',
            'Cable',
            'Case',
            'Screen Protector',
            'Manual',
            'Box',
          ],
        ),
      ],
      validationRules: {
        'minPrice': 10.0,
        'maxPrice': 10000.0,
        'requireImages': true,
        'minImages': 1,
        'maxImages': 10,
      },
    ),
    ProductCategory(
      id: 'books',
      name: 'Books',
      description: 'Textbooks, novels, academic books, and reference materials',
      icon: '📚',
      subcategories: [
        'textbooks',
        'novels',
        'academic',
        'reference',
        'magazines',
        'other',
      ],
      fields: [
        ProductField(
          id: 'title',
          name: 'Book Title',
          type: FieldType.text,
          required: true,
          placeholder: 'Enter the book title',
        ),
        ProductField(
          id: 'author',
          name: 'Author',
          type: FieldType.text,
          required: true,
          placeholder: 'Enter author name',
        ),
        ProductField(
          id: 'isbn',
          name: 'ISBN',
          type: FieldType.text,
          required: false,
          placeholder: '978-0-123456-78-9',
        ),
        ProductField(
          id: 'edition',
          name: 'Edition',
          type: FieldType.text,
          required: false,
          placeholder: 'e.g., 3rd Edition',
        ),
        ProductField(
          id: 'condition',
          name: 'Condition',
          type: FieldType.select,
          required: true,
          options: ['New', 'Like New', 'Good', 'Fair', 'Poor'],
        ),
        ProductField(
          id: 'highlighted',
          name: 'Highlighted/Annotated',
          type: FieldType.select,
          required: false,
          options: ['None', 'Light', 'Moderate', 'Heavy'],
        ),
      ],
      validationRules: {
        'minPrice': 1.0,
        'maxPrice': 500.0,
        'requireImages': true,
        'minImages': 1,
        'maxImages': 5,
      },
    ),
    ProductCategory(
      id: 'clothing',
      name: 'Clothing',
      description: 'Fashion, shoes, accessories, and apparel',
      icon: '👕',
      subcategories: [
        'men',
        'women',
        'shoes',
        'accessories',
        'jewelry',
        'other',
      ],
      fields: [
        ProductField(
          id: 'brand',
          name: 'Brand',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., Nike, Adidas, Zara',
        ),
        ProductField(
          id: 'size',
          name: 'Size',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., M, L, XL, 10, 42',
        ),
        ProductField(
          id: 'color',
          name: 'Color',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., Black, Blue, Red',
        ),
        ProductField(
          id: 'material',
          name: 'Material',
          type: FieldType.text,
          required: false,
          placeholder: 'e.g., Cotton, Polyester, Leather',
        ),
        ProductField(
          id: 'condition',
          name: 'Condition',
          type: FieldType.select,
          required: true,
          options: ['New with Tags', 'Like New', 'Good', 'Fair', 'Poor'],
        ),
      ],
      validationRules: {
        'minPrice': 5.0,
        'maxPrice': 1000.0,
        'requireImages': true,
        'minImages': 2,
        'maxImages': 8,
      },
    ),
    ProductCategory(
      id: 'furniture',
      name: 'Furniture',
      description: 'Home furniture, office furniture, and decor',
      icon: '🪑',
      subcategories: [
        'bedroom',
        'living_room',
        'office',
        'outdoor',
        'storage',
        'other',
      ],
      fields: [
        ProductField(
          id: 'dimensions',
          name: 'Dimensions',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., 120cm x 80cm x 40cm',
        ),
        ProductField(
          id: 'material',
          name: 'Material',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., Wood, Metal, Glass, Plastic',
        ),
        ProductField(
          id: 'color',
          name: 'Color',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., Brown, White, Black',
        ),
        ProductField(
          id: 'condition',
          name: 'Condition',
          type: FieldType.select,
          required: true,
          options: ['New', 'Like New', 'Good', 'Fair', 'Needs Repair'],
        ),
        ProductField(
          id: 'assembly',
          name: 'Assembly Required',
          type: FieldType.select,
          required: false,
          options: ['No', 'Yes', 'Partially'],
        ),
      ],
      validationRules: {
        'minPrice': 20.0,
        'maxPrice': 5000.0,
        'requireImages': true,
        'minImages': 2,
        'maxImages': 10,
      },
    ),
    ProductCategory(
      id: 'vehicles',
      name: 'Vehicles',
      description: 'Cars, motorcycles, bicycles, and transportation',
      icon: '🚗',
      subcategories: [
        'cars',
        'motorcycles',
        'bicycles',
        'scooters',
        'parts',
        'other',
      ],
      fields: [
        ProductField(
          id: 'make',
          name: 'Make',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., Toyota, Honda, BMW',
        ),
        ProductField(
          id: 'model',
          name: 'Model',
          type: FieldType.text,
          required: true,
          placeholder: 'e.g., Camry, Civic, X3',
        ),
        ProductField(
          id: 'year',
          name: 'Year',
          type: FieldType.number,
          required: true,
          placeholder: 'e.g., 2020',
        ),
        ProductField(
          id: 'mileage',
          name: 'Mileage',
          type: FieldType.number,
          required: false,
          placeholder: 'e.g., 50000 km',
        ),
        ProductField(
          id: 'fuel_type',
          name: 'Fuel Type',
          type: FieldType.select,
          required: false,
          options: ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'Other'],
        ),
        ProductField(
          id: 'condition',
          name: 'Condition',
          type: FieldType.select,
          required: true,
          options: ['Excellent', 'Good', 'Fair', 'Poor', 'Non-Running'],
        ),
      ],
      validationRules: {
        'minPrice': 100.0,
        'maxPrice': 100000.0,
        'requireImages': true,
        'minImages': 3,
        'maxImages': 15,
      },
    ),
  ];

  static ProductCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

class ProductField {
  final String id;
  final String name;
  final FieldType type;
  final bool required;
  final String? placeholder;
  final List<String>? options;
  final Map<String, dynamic>? validation;

  const ProductField({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
    this.placeholder,
    this.options,
    this.validation,
  });
}

enum FieldType { text, number, select, multiselect, textarea, date, boolean }
