import 'package:flutter/material.dart';
import 'package:money_management/screens/home/add_transaction_screen/add_transaction_form.dart';
import 'package:money_management/screens/home/widgets/transactions_cards.dart';
import 'package:money_management/screens/home/widgets/hero_card.dart';
import '../../../models/local_db_service.dart';
import '../../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onTransactionAdded; // Callback từ Dashboard
  const HomeScreen({super.key, required this.userId, this.onTransactionAdded});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? currentUser;
  final recentTransactionListKey = GlobalKey<RecentTransactionListState>(); // Thêm key
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    // Nếu bạn đang có email login => truyền vào đây
    final user = await LocalDbService().getUserById(widget.userId);
    setState(() {
      currentUser = user;
    });
  }

  void _dialogBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: AddTransactionForm(
          userId: widget.userId,
          onTransactionAdded: () {
            // Làm mới danh sách giao dịch
            recentTransactionListKey.currentState?.fetchTransactions();
            widget.onTransactionAdded?.call();
          },
        ),
      ),
    ).then((_) {
      _loadCurrentUser(); // Làm mới dữ liệu người dùng để cập nhật HeroCard
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _dialogBuilder(context),
        icon: const Icon(Icons.add),
        label: const Text("Thêm"),
        backgroundColor: Colors.blueAccent.shade100,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent.shade100,
        title: Text(
          "Xin chào, ${currentUser?.username ?? ''}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          const CircleAvatar(
            radius: 14,
            backgroundImage: AssetImage('assets/profile_picture.png'),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          )
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator()) // Đợi load user
          : SingleChildScrollView(
        child: Column(
          children: [
            HeroCard(user: currentUser!), // Đảm bảo userId là String
            TransactionsCards(userId: widget.userId, recentTransactionListKey: recentTransactionListKey,),
          ],
        ),
      ),
    );
  }
}
