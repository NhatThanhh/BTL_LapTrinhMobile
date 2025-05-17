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
    'Dòng tiền',
    'Danh mục',
  ];

  // Màu blue pastel từ time_line_month.dart
  final Color pastelBlue = const Color(0xFF90CAF9);
  final Color pastelBlueDark = const Color(0xFF64B5F6);

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
      BarChartScreen(),
      PieChartScreen()
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Thống kê",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
        toolbarHeight: 56,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int index = 0; index < categories.length; index++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: _selectedIndex == index
                                ? Color(0xFF5CA6E1)
                                : Color(0xFF90CAF9),
                            borderRadius: BorderRadius.circular(15),
                            border: _selectedIndex == index
                                ? Border.all(color: pastelBlueDark)
                                : null,
                          ),
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: chartWidgets[_selectedIndex], // Hiển thị biểu đồ tương ứng với mục được chọn
          ),
        ],
      ),
    );
  }
}