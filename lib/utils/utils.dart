import 'package:flutter/material.dart';
import 'package:money_management/Models/local_db_service.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/models/user_model.dart';

class Utils {
  static void deleteTransaction(
      BuildContext context, String id, VoidCallback onDeleted) async {
    final dbService = LocalDbService();

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

                try {
                  // Lấy thông tin giao dịch trước khi xóa
                  final database = await dbService.db;
                  final transactionMap = await database.query(
                    'transactions',
                    where: 'id = ?',
                    whereArgs: [id],
                    limit: 1,
                  );

                  if (transactionMap.isEmpty) {
                    throw Exception('Transaction not found');
                  }

                  final transaction = TransactionModel.fromMap(transactionMap.first);
                  final type = transaction.type;
                  final amount = transaction.amount;

                  // Bắt đầu transaction SQLite
                  await database.transaction((txn) async {
                    // 1. Xóa giao dịch
                    await txn.delete(
                      'transactions',
                      where: 'id = ?',
                      whereArgs: [id],
                    );

                    // 2. Cập nhật thông tin người dùng
                    final userMap = await txn.query(
                      'users',
                      limit: 1,
                    );

                    if (userMap.isNotEmpty) {
                      final user = UserModel.fromMap(userMap.first);
                      int totalCredit = user.totalCredit;
                      int totalDebit = user.totalDebit;

                      if (type == 'credit') {
                        totalCredit -= amount;
                      } else if (type == 'debit') {
                        totalDebit -= amount;
                      }

                      final remainingAmount = totalCredit - totalDebit;

                      await txn.update(
                        'users',
                        {
                          'totalCredit': totalCredit,
                          'totalDebit': totalDebit,
                          'remainingAmount': remainingAmount,
                        },
                        where: 'id = ?',
                        whereArgs: [user.id],
                      );
                    }
                  });

                  print('Transaction deleted successfully');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa giao dịch thành công')),
                  );

                  // Gọi callback để reload danh sách
                  onDeleted();
                } catch (e) {
                  print('Error deleting transaction: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xóa giao dịch thất bại: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
        static void showSnackBar(BuildContext context, String message) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
  );
  }
}