import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/models/user_model.dart';
import 'package:money_management/screens/home/add_transaction_screen/edit_transaction_form.dart';
import 'package:money_management/screens/home/widgets/transaction_card.dart';

class TransactionsCards extends StatelessWidget {
  final int userId;
  final GlobalKey<RecentTransactionListState> recentTransactionListKey; // Thêm key

  const TransactionsCards({
    super.key,
    required this.userId,
    required this.recentTransactionListKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                "Thu chi gần đây",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RecentTransactionList(
            key: recentTransactionListKey,
            userId: userId,
          ),
        ],
      ),
    );
  }
}

class RecentTransactionList extends StatefulWidget {
  final int userId;

  const RecentTransactionList({super.key, required this.userId});

  @override
  State<RecentTransactionList> createState() => RecentTransactionListState();
}

class RecentTransactionListState extends State<RecentTransactionList> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final data = await LocalDbService().getRecentTransactions(widget.userId);
    setState(() {
      _transactions = data.map((e) => TransactionModel.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteTransaction(int id) async {
    final user = await LocalDbService.instance.getUserById(widget.userId);
    if (user == null) return;

    final transaction = _transactions.firstWhere((tx) => tx.id == id);
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

    await LocalDbService.instance.updateUser(updatedUser); // Sửa insertUser thành updateUser
    await LocalDbService.instance.deleteTransaction(id);
    await fetchTransactions();
  }

  void _showEditTransactionDialog(BuildContext context, TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: EditTransactionScreen(
          userId: widget.userId,
          transaction: transaction,
        ),
      ),
    ).then((_) => fetchTransactions());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Text("Đang tải...");

    if (_transactions.isEmpty) {
      return const Center(child: Text('Không tìm thấy giao dịch nào.'));
    }

    return FutureBuilder<UserModel?>(
      future: LocalDbService.instance.getUserById(widget.userId),
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
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final transaction = _transactions[index];

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
                      _deleteTransaction(transaction.id!);
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
                user: user,
              ),
            );
          },
        );
      },
    );
  }
}