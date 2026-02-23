import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoeListPage extends StatelessWidget {
  const ShoeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shoes")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("shoes").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final shoes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: shoes.length,
            itemBuilder: (context, index) {
              final shoe = shoes[index];
              return ListTile(
                title: Text(shoe['name']),
                subtitle: Text("Price: \$${shoe['price']}"),
              );
            },
          );
        },
      ),
    );
  }
}