import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/models/transaction_model.dart';

class LineChartPage extends StatefulWidget {
  final int userId;
  final DateTime currentMonth;
  const LineChartPage({super.key, required this.userId, required this.currentMonth});

  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  late DateTime currentMonth;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    currentMonth = widget.currentMonth;
  }

  @override
  void didUpdateWidget(covariant LineChartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId || oldWidget.currentMonth != widget.currentMonth) {
      setState(() {
        currentMonth = widget.currentMonth;
      });
    }
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

  Future<List<Map<String, dynamic>>> _fetchChartData() async {
    final monthYear = DateFormat('M/y').format(currentMonth);
    final transactions = await LocalDbService.instance.getTransactionsByFilter(
      userId: widget.userId,
      type: 'credit',
      monthYear: monthYear,
    );

    final debitTransactions = await LocalDbService.instance.getTransactionsByFilter(
      userId: widget.userId,
      type: 'debit',
      monthYear: monthYear,
    );

    final allTransactions = [...transactions, ...debitTransactions];
    allTransactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double runningBalance = 0;
    List<Map<String, dynamic>> dataPoints = [];

    for (var tx in allTransactions) {
      if (tx.type == 'credit') {
        runningBalance += tx.amount;
      } else {
        runningBalance -= tx.amount;
      }
      dataPoints.add({
        'timestamp': tx.timestamp.toDouble(),
        'remainingAmount': runningBalance,
        'monthYear': tx.monthYear,
      });
    }

    return dataPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Biểu đồ tài chính',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                sliver: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchChartData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('Lỗi: ${snapshot.error}')),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Text('Chưa có giao dịch')),
                      );
                    }

                    List<FlSpot> dataPoints = [];
                    Map<double, String> labels = {};

                    for (var data in snapshot.data!) {
                      double xValue = data['timestamp'];
                      double remainingAmount = data['remainingAmount'];
                      String monthYear = data['monthYear'];

                      if (!remainingAmount.isNaN) {
                        dataPoints.add(FlSpot(xValue, remainingAmount));
                        labels[xValue] = '${currencyFormat.format(remainingAmount)}\n$monthYear';
                      }
                    }

                    if (dataPoints.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Text('Không có dữ liệu cho biểu đồ')),
                      );
                    }

                    dataPoints.sort((a, b) => a.x.compareTo(b.x));

                    return SliverToBoxAdapter(
                      child: Container(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.black12, width: 1),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: dataPoints,
                                isCurved: false,
                                color: Colors.blue,
                                barWidth: 4,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.blue,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                              ),
                            ],
                            minX: dataPoints.first.x,
                            maxX: dataPoints.last.x,
                            minY: dataPoints.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
                            maxY: dataPoints.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((touchedSpot) {
                                    final text = labels[touchedSpot.x];
                                    return LineTooltipItem(
                                      text!,
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: previousMonth,
              icon: const Icon(Icons.arrow_back),
              color: Colors.blueAccent,
            ),
            Text(
              DateFormat('M/y').format(currentMonth),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: nextMonth,
              icon: const Icon(Icons.arrow_forward),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}