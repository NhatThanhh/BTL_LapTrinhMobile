import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/models/user_model.dart';
import 'package:money_management/screens/home/add_transaction_screen/add_transaction_form.dart';
import 'package:money_management/screens/transactions/widgets/category_list.dart';
import 'package:money_management/screens/transactions/widgets/time_line_month.dart';
import 'package:money_management/screens/transactions/widgets/tab_bar_view.dart';

class TransactionsScreen extends StatefulWidget {
  final int userId;

  const TransactionsScreen({super.key, required this.userId});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  var category = "Tất cả";
  var monthYear = "";
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      monthYear = DateFormat('M/y').format(now);
    });
  }

  void _dialogBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: AddTransactionForm(userId: widget.userId),
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
    });
  }

  void _searchTransactions(String query) {
    print("Searching for: $query");
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
            hintText: "Search transactions...",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
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
                  });
                }
              },
            ),
            CategoryList(
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    category = value;
                  });
                }
              },
            ),
            TypeTabBar(
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