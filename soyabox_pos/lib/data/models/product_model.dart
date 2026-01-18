class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final int categoryId;
  final bool isAvailable;
  final int? sortOrder;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    required this.categoryId,
    this.isAvailable = true,
    this.sortOrder,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price']?.toDouble() ?? 0.0,
      image: json['image'],
      categoryId: json['category_id'] ?? json['category_id'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      sortOrder: json['sort_order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category_id': categoryId,
      'is_available': isAvailable,
      'sort_order': sortOrder,
    };
  }
}