import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id? id;
  
  late String name;
  int sortOrder = 0;
  bool isDeleted = false;

  Category({
    this.id,
    required this.name,
    this.sortOrder = 0,
    this.isDeleted = false,
  });
}