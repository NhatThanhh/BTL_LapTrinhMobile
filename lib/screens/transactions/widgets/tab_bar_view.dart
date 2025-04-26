import 'package:flutter/material.dart';
import 'package:money_management/screens/transactions/widgets/transaction_list.dart';

class TypeTabBar extends StatefulWidget {
  final int userId;
  final String category;
  final String monthYear;

  const TypeTabBar({
    super.key,
    required this.userId,
    required this.category,
    required this.monthYear,
  });

  @override
  TypeTabBarState createState() => TypeTabBarState();
}

class TypeTabBarState extends State<TypeTabBar> {
  int _refreshCount = 0; // Biến để buộc rebuild TransactionList

  void fetchTransactions() {
    setState(() {
      _refreshCount++;
    });
  }

  void searchTransactions(String query) {
    // Gửi query xuống TransactionList (sẽ cập nhật trong TransactionList)
    setState(() {
      _refreshCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2.0,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: [
                Tab(text: "Thu"),
                Tab(text: "Chi"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TransactionList(
                    key: ValueKey('credit_$_refreshCount'),
                    userId: widget.userId,
                    category: widget.category,
                    monthYear: widget.monthYear,
                    type: 'credit',
                    onTransactionChanged: fetchTransactions,
                  ),
                  TransactionList(
                    key: ValueKey('debit_$_refreshCount'),
                    userId: widget.userId,
                    category: widget.category,
                    monthYear: widget.monthYear,
                    type: 'debit',
                    onTransactionChanged: fetchTransactions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}