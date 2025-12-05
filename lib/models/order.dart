import 'order_item.dart';
import 'table.dart';
import 'user.dart';

class Order {
  final int id;
  final int userId;
  final int tableId;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final String? notes;
  final List<OrderItem> items;
  final TableModel? table;
  final User? user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.tableId,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    this.notes,
    this.items = const [],
    this.table,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      tableId: json['table_id'] is int
          ? json['table_id']
          : int.parse(json['table_id'].toString()),
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: json['total_amount'] is double
          ? json['total_amount']
          : double.parse(json['total_amount'].toString()),
      notes: json['notes'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
      table: json['table'] != null ? TableModel.fromJson(json['table']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'table_id': tableId,
      'order_number': orderNumber,
      'status': status,
      'total_amount': totalAmount,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      if (table != null) 'table': table!.toJson(),
      if (user != null) 'user': user!.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
