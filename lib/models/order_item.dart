import 'menu.dart';

class OrderItem {
  final int? id;
  final int? orderId;
  final int menuId;
  final int quantity;
  final double price;
  final String? notes;
  final Menu? menu;

  OrderItem({
    this.id,
    this.orderId,
    required this.menuId,
    required this.quantity,
    required this.price,
    this.notes,
    this.menu,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      menuId: json['menu_id'] is int
          ? json['menu_id']
          : int.parse(json['menu_id'].toString()),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.parse(json['quantity'].toString()),
      price: json['price'] is double
          ? json['price']
          : double.parse(json['price'].toString()),
      notes: json['notes'],
      menu: json['menu'] != null ? Menu.fromJson(json['menu']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'quantity': quantity,
      'price': price,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  double get total => price * quantity;
}
