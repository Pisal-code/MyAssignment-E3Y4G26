import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shoe.dart';

class ShoeService {
  final CollectionReference shoesCollection =
      FirebaseFirestore.instance.collection('shoes');

  Future<List<Shoe>> getShoes() async {
    try {
      final snapshot = await shoesCollection.get();
      return snapshot.docs
          .map((doc) => Shoe.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print("Firebase Error: $e");
      return [];
    }
  }
}