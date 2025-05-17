import 'package:btl_quanlychitieu/screens/home/add_transaction_screen/add_transaction_form.dart';
import 'package:btl_quanlychitieu/screens/home/home_screen.dart';
import 'package:btl_quanlychitieu/screens/profile/profile_screen.dart';
import 'package:btl_quanlychitieu/screens/statistics/statistics_screen.dart';
import 'package:btl_quanlychitieu/screens/transactions/transactions_screen.dart';
import 'package:btl_quanlychitieu/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var isLogoutLoading = false;
  int currentIndex = 0;

  // Hàm chuyển tab
  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // Hàm hiển thị dialog thêm giao dịch
  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: AddTransactionForm(),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình với HomeScreen nhận callback
    final List<Widget> pageViewList = [
      HomeScreen(onTabChange: changeTab),
      StatisticsScreen(),
      TransactionsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      bottomNavigationBar: Navbar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int value) {
          setState(() {
            currentIndex = value;
          });
        },
        onAddButtonPressed: () => _showAddTransactionDialog(context),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pageViewList,
      ),
    );
  }
}