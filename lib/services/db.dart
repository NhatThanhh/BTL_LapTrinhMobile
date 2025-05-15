import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Db {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> addUser(Map<String, dynamic> data, BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Remove 'password' field if it exists
    data.remove('password');

    try {
      await users.doc(userId).set(data);
      print("User đã thêm");
    } catch (error) {
      _showErrorDialog(context, "Đăng ký thất bại", error.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
