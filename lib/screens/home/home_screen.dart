import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_quanlychitieu/screens/home/widgets/transactions_cards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? user;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Đặt màu nền là trắng
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(-20), // Giảm chiều cao của AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16), // Giảm khoảng cách dưới vì không còn FloatingActionButton
          child: Column(
            children: [
              // HeroCard
              HeroCard(userId: userId),
              SizedBox(height: 2), // Giảm khoảng cách giữa HeroCard và khung giao dịch

              // Phần giao dịch gần đây được bọc trong một khung
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Tiêu đề "Giao dịch gần đây" và nút "Xem tất cả" nằm sát viền trên của khung
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Giao dịch gần đây",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Chuyển tab đến TransactionsScreen (index = 2) trong Dashboard
                                if (widget.onTabChange != null) {
                                  widget.onTabChange!(2); // Gọi callback để thay đổi tab
                                }
                              },
                              child: Text(
                                "Xem tất cả",
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
                      // Phần danh sách giao dịch
                      Expanded(
                        child: TransactionsCards(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}