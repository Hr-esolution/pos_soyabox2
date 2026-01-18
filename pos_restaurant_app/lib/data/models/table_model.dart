class Table {
  final int id;
  final String name;
  final String status; // 'available', 'reserved', 'occupied'
  final String? tableNumber;

  Table({
    required this.id,
    required this.name,
    required this.status,
    this.tableNumber,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? 'available',
      tableNumber: json['table_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'table_number': tableNumber,
    };
  }
}