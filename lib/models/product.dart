class Product {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final int? categoryId;
  final bool? offer;
  final bool? isAvailable;
  final int? sortOrder;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.categoryId,
    this.offer,
    this.isAvailable = true,
    this.sortOrder,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'].toDouble(),
      image: json['image'],
      categoryId: json['category_id'],
      offer: json['offer'],
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
      'offer': offer,
      'is_available': isAvailable,
      'sort_order': sortOrder,
    };
  }
}