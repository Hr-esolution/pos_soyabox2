enum TableStatus { available, reserved, occupied }

class TableModel {
  final int id;
  final String number;
  final TableStatus status;

  TableModel({
    required this.id,
    required this.number,
    this.status = TableStatus.available,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status']?.toString().toLowerCase() ?? 'available';
    TableStatus status = TableStatus.available;
    
    switch(statusStr) {
      case 'reserved':
        status = TableStatus.reserved;
        break;
      case 'occupied':
        status = TableStatus.occupied;
        break;
      default:
        status = TableStatus.available;
    }

    return TableModel(
      id: json['id'] ?? 0,
      number: json['number']?.toString() ?? json['id'].toString() ?? 'N/A',
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': _getStatusString(),
    };
  }

  String _getStatusString() {
    switch(status) {
      case TableStatus.available:
        return 'available';
      case TableStatus.reserved:
        return 'reserved';
      case TableStatus.occupied:
        return 'occupied';
      default:
        return 'available';
    }
  }
}