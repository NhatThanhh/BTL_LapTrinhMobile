import 'package:btl_quanlychitieu/screens/statistics/widgets/bar_chart/bar_chart_screen.dart';
import 'package:btl_quanlychitieu/screens/statistics/widgets/line_chart/line_chart.dart';
import 'package:btl_quanlychitieu/screens/statistics/widgets/pie_chart/pie_chart_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedIndex = 0;
  DateTime currentMonth = DateTime.now();

  final List<String> categories = [
    'Tài chính',
    'Danh mục',
    'Dòng tiền',
  ];

  void previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> chartWidgets = [
      LineChartPage(),
      PieChartScreen(),
      BarChartScreen()
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent.shade100,
        title:
            Text("Thống kê giao dịch", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Thanh cuộn ngang
          Container(
            height: 50, // Độ cao của thanh cuộn
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color:
                          _selectedIndex == index ? Colors.amber : Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: chartWidgets[
                _selectedIndex], // Hiển thị biểu đồ tương ứng với mục được chọn
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
      //         icon: Icon(Icons.arrow_back),
      //         color: Colors.blueAccent,
      //       ),
      //       Text(
      //         DateFormat.yMMM().format(currentMonth),
      //         style: TextStyle(
      //           color: Colors.blueAccent,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       IconButton(
      //         onPressed: nextMonth,
      //         icon: Icon(Icons.arrow_forward),
      //         color: Colors.blueAccent,
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
