import 'category.dart';

class Menu {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imagePath;
  final String? imageUrl;
  final bool isAvailable;
  final Category? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Menu({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imagePath,
    this.imageUrl,
    this.isAvailable = true,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.parse(json['category_id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] is double
          ? json['price']
          : double.parse(json['price'].toString()),
      imagePath: json['image_path'],
      imageUrl: json['image_url'],
      // FIX: Convert int (0/1) to bool
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
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
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_path': imagePath,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      if (category != null) 'category': category!.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
