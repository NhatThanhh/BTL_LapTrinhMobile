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

    print("Fetched ${dataPoints.length} data points for LineChart");
    return dataPoints;
  }
  String formatToMillions(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();

    if (absValue >= 1000000) {
      return '${isNegative ? '-' : ''}${(absValue / 1000000).toStringAsFixed(0)}M';
    } else if (absValue >= 1000) {
      return '${isNegative ? '-' : ''}${(absValue / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   title: const Text(
      //     'Biểu đồ tài chính',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Color(0xFF2C3E50),
      //       fontSize: 22,
      //     ),
      //   ),
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF2FD), // Xanh dương pastel nhạt
              Colors.white,
            ],
            stops: [0.0, 0.7],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchChartData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4285F4)));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có giao dịch',
                        style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
                      ),
                    ],
                  ),
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Không có dữ liệu cho biểu đồ',
                        style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              dataPoints.sort((a, b) => a.x.compareTo(b.x));

              // Tính minY và maxY, làm tròn theo 1 triệu, thêm padding
              double minY = dataPoints.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
              double maxY = dataPoints.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
              minY = (minY / 1000000).floor() * 1000000 - 1000000; // Giảm 1 triệu
              maxY = (maxY / 1000000).ceil() * 1000000 + 1000000; // Tăng 1 triệu
              if (minY == maxY) {
                maxY += 1000000; // Đảm bảo có ít nhất 1 khoảng
                minY -= 1000000;
              }

              return Container(
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1000000, // Lưới theo 1 triệu
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // Không gian cho số tiền
                          interval: 1000000, // Khoảng cách 1 triệu
                          getTitlesWidget: (value, meta) {
                            if (value < minY || value > maxY) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                formatToMillions(value),
                                style: const TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dataPoints,
                        isCurved: false, // Đường thẳng
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4285F4), // Xanh dương
                            Color(0xFF34C759), // Xanh lá
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4285F4).withOpacity(0.2),
                              Colors.white,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: const Color(0xFF4285F4),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                    minX: dataPoints.first.x,
                    maxX: dataPoints.last.x,
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.black.withOpacity(0.8),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((touchedSpot) {
                            final text = labels[touchedSpot.x];
                            return LineTooltipItem(
                              text!,
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: previousMonth,
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFF4285F4),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('M/y').format(currentMonth),
                  style: const TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: nextMonth,
                icon: const Icon(Icons.arrow_forward),
                color: const Color(0xFF4285F4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}