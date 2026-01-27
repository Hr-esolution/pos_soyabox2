import 'dart:convert';

class Product {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final String? categoryId;
  final bool isAvailable;
  final int sortOrder;
  final bool offer;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.categoryId,
    this.isAvailable = true,
    this.sortOrder = 0,
    this.offer = false,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? categoryId,
    bool? isAvailable,
    int? sortOrder,
    bool? offer,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
      offer: offer ?? this.offer,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category_id': categoryId,
      'is_available': isAvailable,
      'sort_order': sortOrder,
      'offer': offer,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'],
      price: map['price']?.toDouble() ?? 0.0,
      image: map['image'],
      categoryId: map['category_id'],
      isAvailable: map['is_available'] ?? true,
      sortOrder: map['sort_order']?.toInt() ?? 0,
      offer: map['offer'] ?? false,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, price: $price, image: $image, categoryId: $categoryId, isAvailable: $isAvailable, sortOrder: $sortOrder, offer: $offer, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.image == image &&
        other.categoryId == categoryId &&
        other.isAvailable == isAvailable &&
        other.sortOrder == sortOrder &&
        other.offer == offer &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      price,
      image,
      categoryId,
      isAvailable,
      sortOrder,
      offer,
      updatedAt,
    );
  }
}