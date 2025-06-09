// lib/models/user.dart

class CartItemData {
  final String productId;
  final int quantity;
  CartItemData({required this.productId, required this.quantity});
  factory CartItemData.fromJson(Map<String, dynamic> j) => CartItemData(
    productId: j['productId'] as String,
    quantity: j['quantity'] as int,
  );
  Map<String, dynamic> toJson() =>
      {'productId': productId, 'quantity': quantity};
}

class User {
  final String id;
  final String email;
  final String name;
  List<String> favorites;
  List<CartItemData> cart;

  User({
    required this.id,
    required this.email,
    required this.name,
    List<String>? favorites,
    List<CartItemData>? cart,
  })  : favorites = favorites ?? [],
        cart = cart ?? [];

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as String,
    email: j['email'] as String,
    name: j['name'] as String,
    favorites: (j['favorites'] as List<dynamic>).cast<String>(),
    cart: (j['cart'] as List<dynamic>)
        .map((e) => CartItemData.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'favorites': favorites,
    'cart': cart.map((e) => e.toJson()).toList(),
  };
}
