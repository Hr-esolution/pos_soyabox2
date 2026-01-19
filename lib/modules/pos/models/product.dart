import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id? id;
  
  late String name;
  late double price;
  String? description;
  late int categoryId;
  bool isAvailable = true;
  int sortOrder = 0;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.description,
    required this.categoryId,
    this.isAvailable = true,
    this.sortOrder = 0,
  });
}