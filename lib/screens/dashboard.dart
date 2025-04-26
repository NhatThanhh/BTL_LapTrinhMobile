import 'package:money_management/screens/home/home_screen.dart';
import 'package:money_management/screens/profile/profile_screen.dart';
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
  late HomeScreen _homeScreen;
  late TransactionsScreen _transactionsScreen;
  final _statisticsScreenKey = GlobalKey<StatisticsScreenState>();
  final _homeScreenKey = GlobalKey();
  final _transactionsScreenKey = GlobalKey();// Thêm GlobalKey cho TransactionsScreen
  @override
  void initState() {
    super.initState();
    _statisticsScreen = StatisticsScreen(
      userId: widget.userId,
      key: _statisticsScreenKey,
    );
    _homeScreen = HomeScreen(
      key: _homeScreenKey,
      userId: widget.userId,
      onTransactionAdded: _refreshScreens,
    );
    _transactionsScreen = TransactionsScreen(
      key: _transactionsScreenKey,
      userId: widget.userId,
      onTransactionAdded: _refreshScreens,
    );
    pageViewList = [
      _homeScreen,
      _statisticsScreen,
      _transactionsScreen,
      ProfileScreen(
        userId: widget.userId,
        onDataRestored: _refreshScreens,
      ),
    ];
  }
  void _refreshScreens() {
    final statisticsState = _statisticsScreenKey.currentState as dynamic;
    final homeState = _homeScreenKey.currentState as dynamic;
    final transactionsState = _transactionsScreenKey.currentState as dynamic;

    statisticsState?.refreshCharts();
    homeState?.fetchTransactions();
    transactionsState?.fetchTransactions();
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
