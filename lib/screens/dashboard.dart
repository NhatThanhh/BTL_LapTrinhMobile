import 'package:money_management/screens/home/home_screen.dart';
// import 'package:quanlychitieu/screens/profile/profile_screen.dart';
import 'package:money_management/screens/statistics/statistics_screen.dart';
import 'package:money_management/screens/transactions/transactions_screen.dart';
import 'package:money_management/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final int userId;
  const Dashboard({super.key, required this.userId});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var isLogoutLoading = false;
  int currentIndex = 0;
  late List<Widget> pageViewList;
  late StatisticsScreen _statisticsScreen;
  final _statisticsScreenKey = GlobalKey<StatisticsScreenState>();
  @override
  void initState() {
    super.initState();
    _statisticsScreen = StatisticsScreen(
      userId: widget.userId,
      key: _statisticsScreenKey,
    );
    // Khởi tạo pageViewList trong initState để sử dụng widget.userId
    pageViewList = [
      HomeScreen(userId: widget.userId,
        onTransactionAdded: () {
          _statisticsScreenKey.currentState?.refreshCharts();
        },),
      _statisticsScreen,
      TransactionsScreen(userId: widget.userId),
      // ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Navbar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pageViewList,
      ),
    );
  }
}
