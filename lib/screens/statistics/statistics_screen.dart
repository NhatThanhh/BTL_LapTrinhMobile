import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_management/screens/statistics/widgets/bar_chart/bar_chart_screen.dart';
import 'package:money_management/screens/statistics/widgets/pie_chart/pie_chart_screen.dart';
import 'package:money_management/screens/statistics/widgets/line_chart/line_chart.dart';


class StatisticsScreen extends StatefulWidget {
  final int userId;
  final GlobalKey<StatisticsScreenState> key;
  const StatisticsScreen({required this.userId, required this.key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedIndex = 0;
  DateTime currentMonth = DateTime.now();
  int _refreshCount = 0;

  final List<String> categories = [
    'Tài chính',
    // 'Danh mục',
    'Dòng tiền',
  ];
  void refreshCharts() {
    setState(() {
      _refreshCount++;
    });
  }
  void previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các biểu đồ
    final chartWidgets = [
      LineChartPage(key: ValueKey('line_$_refreshCount'), userId: widget.userId, currentMonth: currentMonth),
      // PieChartScreen(userId: _userId ?? 0, currentMonth: currentMonth),
      BarChartScreen(key: ValueKey('bar_$_refreshCount'), userId: widget.userId, currentMonth: currentMonth),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(
          "Thống kê giao dịch",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Thanh điều hướng giữa các loại biểu đồ
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: _selectedIndex == index
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                          : null,
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: _selectedIndex == index ? Colors.white : Colors.black,
                        fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Widget biểu đồ được chọn
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: chartWidgets,
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.white,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       IconButton(
      //         onPressed: previousMonth,
      //         icon: const Icon(Icons.arrow_back),
      //         color: Colors.blueAccent,
      //       ),
      //       Text(
      //         DateFormat('M/y').format(currentMonth),
      //         style: const TextStyle(
      //           color: Colors.blueAccent,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       IconButton(
      //         onPressed: nextMonth,
      //         icon: const Icon(Icons.arrow_forward),
      //         color: Colors.blueAccent,
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}