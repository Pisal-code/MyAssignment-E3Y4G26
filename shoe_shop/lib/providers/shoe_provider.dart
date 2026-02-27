import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shoe.dart';

class ShoeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Shoe> _allShoes = [];
  List<Shoe> _filteredShoes = [];
  List<Shoe> _newArrivals = [];
  List<Shoe> _recommendedShoes = [];
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedCategoryIndex;

  // Getters
  List<Shoe> get allShoes => _allShoes;
  List<Shoe> get filteredShoes => _filteredShoes;
  List<Shoe> get newArrivals => _newArrivals;
  List<Shoe> get recommendedShoes => _recommendedShoes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryIndex => _selectedCategoryIndex;

  final List<String> categories = [
    "Running",
    "Jordan",
    "Skate",
    "Lifestyle",
    "Hiking",
    "Casual",
  ];

  // Initialize - listen to Firestore changes
  ShoeProvider() {
    _init();
  }

  void _init() {
    _firestore.collection('shoes').snapshots().listen(
      (snapshot) {
        _allShoes = snapshot.docs
            // ignore: unnecessary_cast
            .map((doc) => Shoe.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
            .toList();
        _applyFilters();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void _applyFilters() {
    _filteredShoes = _allShoes.where((shoe) {
      // Category filter
      if (_selectedCategoryIndex != null) {
        if (shoe.category != categories[_selectedCategoryIndex!]) {
          return false;
        }
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!shoe.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    // Update new arrivals (sorted by id descending - newest first)
    _newArrivals = List<Shoe>.from(_filteredShoes)
      ..sort((a, b) => b.id.compareTo(a.id));

    // Update recommended (best selling)
    _recommendedShoes = _filteredShoes.where((shoe) => shoe.bestSelling).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(int? index) {
    _selectedCategoryIndex = index;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryIndex = null;
    _applyFilters();
    notifyListeners();
  }

  // Get shoe by ID
  Shoe? getShoeById(String id) {
    try {
      return _allShoes.firstWhere((shoe) => shoe.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get shoes by category
  List<Shoe> getShoesByCategory(String category) {
    return _allShoes.where((shoe) => shoe.category == category).toList();
  }
}

