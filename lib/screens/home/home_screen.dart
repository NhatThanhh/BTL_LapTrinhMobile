import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_quanlychitieu/screens/home/add_transaction_screen/add_transaction_form.dart';
import 'package:btl_quanlychitieu/screens/home/widgets/transactions_cards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:btl_quanlychitieu/screens/transactions/transactions_screen.dart';
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

  _dialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: AddTransactionForm(),
          );
        });
  }

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
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _dialogBuilder(context);
        },
        icon: Icon(Icons.add),
        label: Text("Thêm"),
        backgroundColor: Colors.blueAccent.shade100,
      ),
      // Thu nhỏ AppBar bằng cách giảm kích thước và sử dụng PreferredSize
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(20), // Giảm chiều cao của AppBar
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
          actions: [
            // Giảm khoảng cách giữa các phần tử
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(user!.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                    return CircleAvatar(
                      radius: 30, // Giảm kích thước avatar
                      backgroundImage: AssetImage('assets/profile_picture.png'),
                    );
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>;

                  return CircleAvatar(
                    radius: 30, // Giảm kích thước avatar
                    backgroundImage: userData['avatarUrl'] != null
                        ? NetworkImage(userData['avatarUrl'])
                        : AssetImage('assets/profile_picture.png') as ImageProvider,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // HeroCard được giữ nguyên nhưng đã có không gian nhiều hơn vì AppBar đã được thu nhỏ
          HeroCard(userId: userId),
          // Thêm một đường phân cách nhỏ
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
          // Thêm tiêu đề cho phần giao dịch
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
          // Phần danh sách giao dịch
          Expanded(
            child: SingleChildScrollView(
              child: TransactionsCards(),
            ),
          ),
        ],
      ),
    );
  }
}