import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LineChartPage extends StatefulWidget {
  const LineChartPage({Key? key}) : super(key: key);

  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  DateTime currentMonth = DateTime.now();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

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

  String formatToMillions(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();

    if (absValue >= 1e6) {
      return '${isNegative ? '-' : ''}${(absValue / 1e6).toStringAsFixed(0)}M';
    } else if (absValue >= 1e3) {
      return '${isNegative ? '-' : ''}${(absValue / 1e3).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để xem biểu đồ')),
      );
    }
    final userId = user.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('transactions')
                .where(
              'monthyear',
              isEqualTo: DateFormat('M/y').format(currentMonth),
            )
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4285F4)));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi: ${snapshot.error}',
                        style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
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

              // Xây dựng các điểm dữ liệu và nhãn
              final List<FlSpot> dataPoints = [];
              final Map<double, String> labels = {};
              final List<Map<String, dynamic>> transactions = [];

              // Thu thập dữ liệu giao dịch
              for (var doc in docs) {
                final data = doc.data()! as Map<String, dynamic>;
                final timestamp = data['timestamp'] as num? ?? 0;
                final remaining = (data['remainingAmount'] as num?)?.toDouble();
                final monthYear = data['monthyear'] as String? ?? '';

                if (remaining != null) {
                  transactions.add({
                    'timestamp': timestamp,
                    'remaining': remaining,
                    'monthYear': monthYear,
                  });
                }
              }

              // Sắp xếp các giao dịch theo thời gian (tăng dần)
              transactions.sort((a, b) => (a['timestamp'] as num).compareTo(b['timestamp'] as num));

              // Tạo vị trí x có khoảng cách đều nhau
              for (int i = 0; i < transactions.length; i++) {
                // Sử dụng chỉ số làm tọa độ x để tạo khoảng cách đều nhau
                final x = i.toDouble();
                final remaining = transactions[i]['remaining'] as double;
                final monthYear = transactions[i]['monthYear'] as String;
                final timestamp = transactions[i]['timestamp'] as num;

                dataPoints.add(FlSpot(x, remaining));
                labels[x] = '${currencyFormat.format(remaining)}\n$monthYear';
              }

              // Tính toán minY và maxY với phần đệm
              double minY = dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b);
              double maxY = dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b);
              minY = (minY / 1e6).floor() * 1e6 - 1e6;
              maxY = (maxY / 1e6).ceil() * 1e6 + 1e6;
              if (minY == maxY) {
                minY -= 1e6;
                maxY += 1e6;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.show_chart, color: Color(0xFF4285F4), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Biến động số dư',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 1e6,
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                            getDrawingVerticalLine: (_) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 1e6,
                                getTitlesWidget: (value, _) {
                                  if (value < minY || value > maxY) return const SizedBox();
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      formatToMillions(value),
                                      style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade200, width: 1)),
                          lineBarsData: [
                            LineChartBarData(
                              spots: dataPoints,
                              isCurved: false,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4285F4), Color(0xFF34C759)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              barWidth: 4,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF4285F4).withOpacity(0.2), Colors.white],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                                  radius: 6,
                                  color: const Color(0xFF4285F4),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          minX: 0,
                          maxX: dataPoints.isEmpty ? 0 : dataPoints.length - 1,
                          minY: minY,
                          maxY: maxY,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => Colors.black.withOpacity(0.8),
                              getTooltipItems: (spots) => spots.map((spot) {
                                final text = labels[spot.x] ?? '';
                                return LineTooltipItem(text, const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14));
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMonthButton(Icons.arrow_back, previousMonth),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFE6F0FF), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  DateFormat('M/y').format(currentMonth),
                  style: const TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildMonthButton(Icons.arrow_forward, nextMonth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
      ]),
      child: IconButton(
        icon: Icon(icon),
        color: const Color(0xFF4285F4),
        onPressed: onPressed,
      ),
    );
  }
}