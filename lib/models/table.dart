class TableModel {
  final int id;
  final String tableNumber;
  final int capacity;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      tableNumber: json['table_number'] ?? '',
      capacity: json['capacity'] is int
          ? json['capacity']
          : int.parse(json['capacity'].toString()),
      status: json['status'] ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
