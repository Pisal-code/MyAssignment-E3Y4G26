import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shoe.dart';

class CartItem {
  final String id;
  final String shoeId;
  final String name;
  final double price;
  final double? oldPrice;
  final String? imageUrl;
  final String size;
  int quantity;
  final DateTime? createdAt;

  CartItem({
    required this.id,
    required this.shoeId,
    required this.name,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    required this.size,
    this.quantity = 1,
    this.createdAt,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'shoeId': shoeId,
      'name': name,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'size': size,
      'quantity': quantity,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String docId) {
    return CartItem(
      id: docId,
      shoeId: map['shoeId']?.toString() ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      oldPrice: map['oldPrice']?.toDouble(),
      imageUrl: map['imageUrl'] ?? map['image'],
      size: map['size'] ?? 'N/A',
      quantity: map['quantity'] ?? 1,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  String _uid = '';

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.length;
  
  double get totalMRP {
    // ignore: avoid_types_as_parameter_names
    return _cartItems.fold(0.0, (sum, item) {
      double price = item.oldPrice ?? item.price;
      return sum + (price * item.quantity);
    });
  }

  double get totalSelling {
    // ignore: avoid_types_as_parameter_names
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double get discount => totalMRP - totalSelling;
  double get platformFee => 2.0;
  double get shippingFee => 0.0;
  double get totalAmount => totalSelling + platformFee;

  // Initialize with user ID
  void init(String uid) {
    _uid = uid;
    if (uid.isEmpty) return;
    _listenToCart(uid);
  }

  void _listenToCart(String uid) {
    _firestore
        .collection('cart')
        .doc(uid)
        .collection('items')
        .snapshots()
        .listen(
          (snapshot) {
            _cartItems = snapshot.docs
                .map((doc) => CartItem.fromMap(
                      // ignore: unnecessary_cast
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ))
                .toList();
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> addToCart(Shoe shoe, String size, {int quantity = 1}) async {
    if (_uid.isEmpty) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      final cartRef = _firestore
          .collection('cart')
          .doc(_uid)
          .collection('items');

      // Check if item exists with same shoeId and size
      final existingItem = await cartRef
          .where('shoeId', isEqualTo: shoe.id)
          .where('size', isEqualTo: size)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Update quantity
        await cartRef.doc(existingItem.docs.first.id).update({
          'quantity': existingItem.docs.first['quantity'] + quantity,
        });
      } else {
        // Add new item
        await cartRef.add({
          'shoeId': shoe.id,
          'name': shoe.name,
          'price': shoe.price,
          'oldPrice': shoe.oldPrice,
          'imageUrl': shoe.imageUrl,
          'size': size,
          'quantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity < 1) return;
    
    try {
      await _firestore
          .collection('cart')
          .doc(_uid)
          .collection('items')
          .doc(cartItemId)
          .update({'quantity': quantity});
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _firestore
          .collection('cart')
          .doc(_uid)
          .collection('items')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('cart')
          .doc(_uid)
          .collection('items')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> checkout() async {
    // This is handled by the cart_screen for now
    // Could be extended to create order in Firestore
  }
}

