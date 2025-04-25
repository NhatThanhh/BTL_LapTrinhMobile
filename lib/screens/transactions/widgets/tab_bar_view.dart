import 'package:flutter/material.dart';
import 'package:money_management/screens/transactions/widgets/transaction_list.dart';

class TypeTabBar extends StatelessWidget {
  final int userId;
  final String category;
  final String monthYear;

  const TypeTabBar({
    Key? key,
    required this.userId,
    required this.category,
    required this.monthYear,
  }) : super(key: key);

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
                    userId: userId,
                    category: category,
                    monthYear: monthYear,
                    type: 'credit',
                  ),
                  TransactionList(
                    userId: userId,
                    category: category,
                    monthYear: monthYear,
                    type: 'debit',
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