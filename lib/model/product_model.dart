class Product {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String category;
  final String? details;
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    this.details,
    this.imagePath,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['product_name'],
      price: map['product_price'].toDouble(),
      quantity: map['product_quantity'],
      category: map['category'],
      details: map['details'],
      imagePath: map['image_path'],
    );
  }
}
