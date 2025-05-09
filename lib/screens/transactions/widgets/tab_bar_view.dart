import 'package:flutter/material.dart';
import 'package:money_management/screens/transactions/widgets/transaction_list.dart';

// Phiên bản cập nhật cho TypeTabBar với tabs Thu/Chi đẹp hơn
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

class TypeTabBarState extends State<TypeTabBar> with SingleTickerProviderStateMixin {
  int _refreshCount = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Cập nhật UI khi tab thay đổi
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchTransactions() {
    setState(() {
      _refreshCount++;
    });
  }

  void searchTransactions(String query) {
    setState(() {
      _refreshCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2.0,
      child: Column(
        children: <Widget>[
          // TabBar đã được cập nhật theo yêu cầu
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Tab "Thu"
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? Colors.green.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25), // Bo góc cho tab Thu
                        border: Border.all(
                          color: _tabController.index == 0
                              ? Colors.green.withOpacity(0.5)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 20,
                            color: _tabController.index == 0 ? Colors.green : Colors.black87,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Thu",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _tabController.index == 0 ? Colors.green : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12), // Khoảng cách giữa hai tab

                // Tab "Chi"
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? Colors.red.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25), // Bo góc cho tab Chi
                        border: Border.all(
                          color: _tabController.index == 1
                              ? Colors.red.withOpacity(0.5)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 20,
                            color: _tabController.index == 1 ? Colors.red : Colors.black87,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Chi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _tabController.index == 1 ? Colors.red : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
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
    );
  }
}