import 'package:flutter/material.dart';
import 'package:money_management/screens/home/add_transaction_screen/add_transaction_form.dart';
import 'package:money_management/screens/home/widgets/transactions_cards.dart';
import 'package:money_management/screens/home/widgets/hero_card.dart';
import '../../../models/local_db_service.dart';
import '../../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onTransactionAdded;
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
    final user = await LocalDbService().getUserById(widget.userId);
    setState(() {
      currentUser = user;
    });
  }

  void fetchTransactions() {
    recentTransactionListKey.currentState?.fetchTransactions();
    _loadCurrentUser(); // Làm mới HeroCard
  }

  void _dialogBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: AddTransactionForm(
          userId: widget.userId,
          onTransactionAdded: () {
            fetchTransactions();
            widget.onTransactionAdded?.call();
          },
        ),
      ),
    ).then((_) {
      _loadCurrentUser();
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
          : Stack(
        children: [
          // Nội dung cuộn
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 240.0), // Dành không gian cho HeroCard
            child: Column(
              children: [
                TransactionsCards(
                  userId: widget.userId,
                  recentTransactionListKey: recentTransactionListKey,
                  onUserDataChanged: () {
                    // Cập nhật lại dữ liệu người dùng để làm mới HeroCard
                    _loadCurrentUser();
                  },
                ),
              ],
            ),
          ),
          // HeroCard cố định trên cùng
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HeroCard(user: currentUser!), // Đảm bảo userId là String
          ),
        ],
      ),
    );
  }
}
