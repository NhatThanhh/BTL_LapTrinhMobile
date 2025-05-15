import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_quanlychitieu/screens/home/widgets/transaction_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../utils/utils.dart';
import '../../home/add_transaction_screen/edit_transaction_form.dart';

class TransactionList extends StatelessWidget {
  TransactionList({
    super.key,
    required this.category,
    required this.type,
    required this.monthYear,
  });

  final userId = FirebaseAuth.instance.currentUser!.uid;

  final String category;
  final String type;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    // Khởi tạo truy vấn cơ bản
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("transactions")
        .orderBy('timestamp', descending: true)
        .where('monthyear', isEqualTo: monthYear);

    // Chỉ thêm bộ lọc type nếu type không phải 'all'
    if (type != 'all') {
      query = query.where('type', isEqualTo: type);
    }

    // Thêm bộ lọc category nếu không phải 'Tất cả'
    if (category != 'Tất cả') {
      query = query.where('category', isEqualTo: category);
    }

    return FutureBuilder<QuerySnapshot>(
      future: query.limit(150).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Đã xảy ra lỗi');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Đang tải...");
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không tìm thấy giao dịch nào.'));
        }
        var data = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            var cardData = data[index];
            var transactionId = cardData.id;

            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      _showEditTransactionDialog(
                          context, userId, transactionId, cardData);
                    },
                    backgroundColor: const Color(0xFF7BC043),
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Sửa',
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      Utils.deleteTransaction(
                          context, userId, transactionId, cardData);
                    },
                    backgroundColor: const Color(0xFFFC0707),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Xóa',
                  ),
                ],
              ),
              child: TransactionCard(
                data: cardData,
              ),
            );
          },
        );
      },
    );
  }
}

void _showEditTransactionDialog(BuildContext context, String userId,
    String transactionId, DocumentSnapshot cardData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: EditTransactionScreen(
          userData: null,
          transactionData: cardData.data() as Map<String, dynamic>?,
        ),
      );
    },
  );
}