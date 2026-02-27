import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shoe.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Shoe> _favorites = [];
  bool _isLoading = false;
  String? _error;
  String _uid = '';

  // Getters
  List<Shoe> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get favoriteCount => _favorites.length;

  // Initialize with user ID - per-user favorites
  void init(String uid) {
    _uid = uid;
    if (uid.isEmpty) {
      _favorites = [];
      notifyListeners();
      return;
    }
    _listenToFavorites(uid);
  }

  void _listenToFavorites(String uid) {
    _firestore
        .collection('favorites')
        .doc(uid)
        .collection('items')
        .snapshots()
        .listen(
          (snapshot) {
            _favorites = snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  // Create shoe from favorite item data
                  return Shoe(
                    id: data['shoeId'] ?? '',
                    name: data['name'] ?? '',
                    description: data['description'] ?? '',
                    price: (data['price'] ?? 0).toDouble(),
                    oldPrice: data['oldPrice']?.toDouble(),
                    imageUrl: data['imageUrl'],
                    status: data['status'] ?? 'Active',
                    bestSelling: data['bestSelling'] ?? false,
                    stock: data['stock'] ?? 0,
                    isFavorite: true,
                    category: data['category'] ?? 'Uncategorized',
                  );
                })
                .toList();
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  bool isFavorite(String shoeId) {
    return _favorites.any((shoe) => shoe.id == shoeId);
  }

  Future<void> toggleFavorite(Shoe shoe) async {
    if (_uid.isEmpty) return;
    
    try {
      final alreadyFavorite = isFavorite(shoe.id);
      
      if (alreadyFavorite) {
        // Remove from favorites
        await _firestore
            .collection('favorites')
            .doc(_uid)
            .collection('items')
            .where('shoeId', isEqualTo: shoe.id)
            .get()
            .then((snapshot) {
              for (var doc in snapshot.docs) {
                doc.reference.delete();
              }
            });
        
        _favorites.removeWhere((s) => s.id == shoe.id);
      } else {
        // Add to favorites
        await _firestore
            .collection('favorites')
            .doc(_uid)
            .collection('items')
            .add({
              'shoeId': shoe.id,
              'name': shoe.name,
              'description': shoe.description,
              'price': shoe.price,
              'oldPrice': shoe.oldPrice,
              'imageUrl': shoe.imageUrl,
              'status': shoe.status,
              'bestSelling': shoe.bestSelling,
              'stock': shoe.stock,
              'category': shoe.category,
              'addedAt': FieldValue.serverTimestamp(),
            });
        
        // Add to local list
        if (!_favorites.any((s) => s.id == shoe.id)) {
          _favorites.add(shoe);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(String shoeId) async {
    if (_uid.isEmpty) return;
    
    try {
      await _firestore
          .collection('favorites')
          .doc(_uid)
          .collection('items')
          .where('shoeId', isEqualTo: shoeId)
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });
      
      _favorites.removeWhere((s) => s.id == shoeId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addToFavorites(Shoe shoe) async {
    if (_uid.isEmpty) return;
    
    try {
      // Check if already favorite
      if (!isFavorite(shoe.id)) {
        await _firestore
            .collection('favorites')
            .doc(_uid)
            .collection('items')
            .add({
              'shoeId': shoe.id,
              'name': shoe.name,
              'description': shoe.description,
              'price': shoe.price,
              'oldPrice': shoe.oldPrice,
              'imageUrl': shoe.imageUrl,
              'status': shoe.status,
              'bestSelling': shoe.bestSelling,
              'stock': shoe.stock,
              'category': shoe.category,
              'addedAt': FieldValue.serverTimestamp(),
            });
        
        _favorites.add(shoe);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}

