import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_management/screens/home/add_transaction_screen/add_transaction_form.dart';
import 'package:money_management/screens/transactions/widgets/category_list.dart';
import 'package:money_management/screens/transactions/widgets/time_line_month.dart';
import 'package:money_management/screens/transactions/widgets/tab_bar_view.dart';

class TransactionsScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onTransactionAdded;

  const TransactionsScreen({
    super.key,
    required this.userId,
    this.onTransactionAdded,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  var category = "Tất cả";
  var monthYear = "";
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  final typeTabBarKey = GlobalKey<TypeTabBarState>();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      monthYear = DateFormat('M/y').format(now);
    });
  }

  void fetchTransactions() {
    typeTabBarKey.currentState?.fetchTransactions();
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
    );
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      typeTabBarKey.currentState?.searchTransactions('');
    });
  }

  void _searchTransactions(String query) {
    typeTabBarKey.currentState?.searchTransactions(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogBuilder(context),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent.shade100,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent.shade100,
        title: !isSearching
            ? const Text("Giao dịch", style: TextStyle(color: Colors.white))
            : TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Tìm kiếm giao dịch...",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          autofocus: true,
          onChanged: _searchTransactions,
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
            icon: Icon(isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TimeLineMonth(
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    monthYear = value;
                    fetchTransactions();
                  });
                }
              },
            ),
            CategoryList(
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    category = value;
                    fetchTransactions();
                  });
                }
              },
            ),
            TypeTabBar(
              key: typeTabBarKey,
              userId: widget.userId,
              category: category,
              monthYear: monthYear,
            ),
          ],
        ),
      ),
    );
  }
}