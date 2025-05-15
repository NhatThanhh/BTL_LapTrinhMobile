import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_quanlychitieu/screens/home/widgets/transaction_card.dart';
import 'package:btl_quanlychitieu/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../add_transaction_screen/edit_transaction_form.dart';

class TransactionsCards extends StatelessWidget {
  TransactionsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          RecentTransactionList()
        ],
      ),
    );
  }
}

class RecentTransactionList extends StatelessWidget {
  RecentTransactionList({
    super.key,
  });

  final userId = FirebaseAuth.instance.currentUser!.uid;

  get doNothing => null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection("transactions")
            .orderBy('timestamp', descending: true)
            .limit(5)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData == snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không tìm thấy giao dịch nào.'));
          }
          var data = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                        print('Sửa');
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
        });
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
          transactionData:
          cardData.data() as Map<String, dynamic>?,
        ),
      );
    },
  );
}