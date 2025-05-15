import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Utils {
  static void deleteTransaction(BuildContext context, String userId, String id,
      DocumentSnapshot cardData) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có muốn xóa giao dịch này không?'),
            actions: <Widget>[
              TextButton(
                child: Text('Hủy'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: Text('Xóa'),
                  onPressed: () async {
                    Navigator.of(context).pop();

                    String type = cardData['type'];
                    int amount = cardData['amount'];
                    int timestamp = cardData['timestamp'];

                    try {
                      await FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        // Xóa giao dịch
                        transaction.delete(
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection("transactions")
                              .doc(id),
                        );

                        // Lấy thông tin người dùng để cập nhật lại
                        DocumentSnapshot userSnapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(userId)
                            .get();

                        int totalCredit = userSnapshot['totalCredit'];
                        int totalDebit = userSnapshot['totalDebit'];
                        int remainingAmount = userSnapshot['remainingAmount'];

                        // Cập nhật lại các giá trị totalCredit, totalDebit và remainingAmount
                        if (type == 'credit') {
                          totalCredit -= amount;
                        } else if (type == 'debit') {
                          totalDebit -= amount;
                        }

                        remainingAmount = totalCredit - totalDebit;

                        // Cập nhật vào bảng users
                        transaction.update(
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId),
                          {
                            'totalCredit': totalCredit,
                            'totalDebit': totalDebit,
                            'remainingAmount': remainingAmount,
                          },
                        );

                        // Lấy tất cả các giao dịch sau bản ghi bị xóa, sắp xếp theo timestamp
                        QuerySnapshot transactionsSnapshot =
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection("transactions")
                                .orderBy('timestamp')
                                .startAfter([timestamp]).get();

                        // Duyệt qua tất cả các giao dịch để tính toán lại các giá trị remainingAmount, totalCredit và totalDebit
                        for (DocumentSnapshot doc
                            in transactionsSnapshot.docs) {
                          int totalCredit = doc['totalCredit'];
                          int totalDebit = doc['totalDebit'];

                          if (type == 'credit') {
                            totalCredit -= amount;
                          } else if (type == 'debit') {
                            totalDebit -= amount;
                          }

                          int remainingAmount = totalCredit - totalDebit;

                          transaction.update(doc.reference, {
                            'totalCredit': totalCredit,
                            'totalDebit': totalDebit,
                            'remainingAmount': remainingAmount,
                          });
                        }
                      });

                      print('Transaction deleted successfully');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Transaction deleted')),
                      );
                    } catch (e) {
                      print('Error deleting transaction: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete transaction')),
                      );
                    }
                  }),
            ],
          );
        });
  }
}
