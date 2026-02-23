class Shoe {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String? imageUrl;
  final String status;
  final bool bestSelling;
  final int stock;
  bool isFavorite;
  final String category;

  Shoe({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    required this.status,
    this.bestSelling = false,
    required this.stock,
    this.isFavorite = false,
    required this.category,
  });

  // JSON from API
  factory Shoe.fromJson(Map<String, dynamic> json) {
    return Shoe(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      oldPrice: json['old_price'] != null ? double.tryParse(json['old_price'].toString()) : null,
      imageUrl: json['image_url'],
      status: json['status'] ?? 'Active',
      bestSelling: json['bestSelling'] ?? false,
      stock: json['stock'] is int ? json['stock'] : int.parse(json['stock'].toString()),
      isFavorite: json['is_favorite'] ?? false,
      category: json['category'] ?? 'Uncategorized',
    );
  }

  // Firebase Firestore factory
  factory Shoe.fromMap(Map<String, dynamic> map, {String? docId}) {
  return Shoe(
    id: docId ?? '',
    name: map['name'] ?? 'Unknown',
    description: map['description'] ?? '',
    price: map['price'] != null
        ? double.tryParse(map['price'].toString()) ?? 0.0
        : 0.0,
    oldPrice: map['old_price'] != null
        ? double.tryParse(map['old_price'].toString())
        : null,
    imageUrl: map['image_url'],
    status: map['status'] ?? 'Active',
    bestSelling: map['bestSelling'] ?? false,
    stock: map['stock'] is int
        ? map['stock']
        : int.tryParse(map['stock'].toString()) ?? 0,
    isFavorite: map['is_favorite'] ?? false, // ✅ FIXED
    category: map['category'] ?? 'Uncategorized',
  );
}

  Object? get images => null;
  Object? get sizes => null;
}