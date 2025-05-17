import 'package:btl_quanlychitieu/screens/dashboard.dart';
import 'package:btl_quanlychitieu/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'db.dart';

class AuthService {
  var db = Db();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  createUser(data, context) async {
    try {
      // 1. Tạo account với FirebaseAuth
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      final uid = userCred.user!.uid;

      // 2. Tạo document trong Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'username': data['username'],
        'email': data['email'],
        'phone': data['phone'],
        'remainingAmount': data['remainingAmount'],
        'totalCredit': data['totalCredit'],
        'totalDebit': data['totalDebit'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Điều hướng về Login (hoặc Dashboard tuỳ flow)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Đăng ký thất bại"),
              content: Text(e.toString()),
            );
          });
    }
  }

  login(data, context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => Dashboard()),
      // );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Đăng nhập thất bại"),
              content: Text(e.toString()),
            );
          });
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng đã hủy đăng nhập
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await db.users.doc(user.uid).get();
        if (!userDoc.exists) {
          final userData = {
            "username": user.displayName ?? '',
            "email": user.email ?? '',
            "phone": user.phoneNumber ?? '',
            'remainingAmount': 0,
            'totalCredit': 0,
            'totalDebit': 0
          };
          await db.addUser(userData, context);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
    } catch (e) {
      _showErrorDialog(context, "Đăng nhập bằng Google thất bại", e.toString());
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
