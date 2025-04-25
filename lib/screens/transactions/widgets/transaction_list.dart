import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/screens/home/add_transaction_screen/edit_transaction_form.dart';
import 'package:money_management/screens/home/widgets/transaction_card.dart';
import 'package:money_management/models/user_model.dart';

class TransactionList extends StatelessWidget {
  final int userId;
  final String category;
  final String type;
  final String monthYear;

  const TransactionList({
    super.key,
    required this.userId,
    required this.category,
    required this.type,
    required this.monthYear,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionModel>>(
      future: LocalDbService.instance.getTransactionsByFilter(
        userId: userId,
        type: type,
        monthYear: monthYear,
        category: category == 'Tất cả' ? null : category,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Đã xảy ra lỗi');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Đang tải...');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không tìm thấy giao dịch nào.'));
        }

        final transactions = snapshot.data!;
        return FutureBuilder<UserModel?>(
          future: LocalDbService.instance.getUserById(userId),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!userSnapshot.hasData) {
              return const Center(child: Text('Không tìm thấy người dùng.'));
            }

            final user = userSnapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _showEditTransactionDialog(context, transaction);
                        },
                        backgroundColor: const Color(0xFF7BC043),
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Sửa',
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          _deleteTransaction(context, transaction, user);
                        },
                        backgroundColor: const Color(0xFFFC0707),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Xóa',
                      ),
                    ],
                  ),
                  child: TransactionCard(
                    data: transaction,
                    user: user, // Truyền UserModel
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showEditTransactionDialog(BuildContext context, TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: EditTransactionScreen(
          userId: userId,
          transaction: transaction,
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(BuildContext context, TransactionModel transaction, UserModel user) async {
    // Hoàn tác ảnh hưởng của giao dịch
    int newRemaining = user.remainingAmount;
    int newTotalCredit = user.totalCredit;
    int newTotalDebit = user.totalDebit;

    if (transaction.type == 'credit') {
      newRemaining -= transaction.amount;
      newTotalCredit -= transaction.amount;
    } else {
      newRemaining += transaction.amount;
      newTotalDebit -= transaction.amount;
    }

    final updatedUser = UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      password: user.password,
      phone: user.phone,
      remainingAmount: newRemaining,
      totalCredit: newTotalCredit,
      totalDebit: newTotalDebit,
    );

    await LocalDbService.instance.insertUser(updatedUser);
    await LocalDbService.instance.deleteTransaction(transaction.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Giao dịch đã được xóa')),
    );
  }
}