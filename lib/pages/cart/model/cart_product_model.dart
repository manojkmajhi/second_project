class CartProductModel {
  final String productId;
  final String productName;
  final double productPrice;
  final String? imagePath; // Nullable as it might not always be present
  int quantity;

  CartProductModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.imagePath,
    this.quantity = 1,
  });

  // Factory constructor to create a CartProductModel from a JSON map
  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productPrice: double.tryParse(json['product_price'].toString()) ?? 0.0,
      imagePath: json['image_path'] as String?,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  // Method to convert CartProductModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'image_path': imagePath,
      'quantity': quantity,
    };
  }

  // Method to copy the CartProductModel with updated values
  CartProductModel copyWith({
    String? productId,
    String? productName,
    double? productPrice,
    String? imagePath,
    int? quantity,
  }) {
    return CartProductModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
    );
  }
}