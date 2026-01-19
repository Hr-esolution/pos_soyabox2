import 'package:isar/isar.dart';

part 'table_model.g.dart';

enum TableStatus { available, reserved, occupied }

@collection
class TableModel {
  Id? id;
  
  late int number;
  late TableStatus status;
  int gridColumnStart = 1;
  int gridColumnEnd = 2;
  int gridRowStart = 1;
  int gridRowEnd = 2;

  TableModel({
    this.id,
    required this.number,
    this.status = TableStatus.available,
    this.gridColumnStart = 1,
    this.gridColumnEnd = 2,
    this.gridRowStart = 1,
    this.gridRowEnd = 2,
  });
}