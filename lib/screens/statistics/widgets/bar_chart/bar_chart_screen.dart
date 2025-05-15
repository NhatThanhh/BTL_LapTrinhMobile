import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cash_flow.dart';

class Transaction {
  final double remainingAmount;
  final String monthYear;
  final double totalCredit;
  final double totalDebit;
  final int timestamp;

  Transaction({
    required this.remainingAmount,
    required this.monthYear,
    required this.totalCredit,
    required this.totalDebit,
    required this.timestamp,
  });

  factory Transaction.fromDocument(DocumentSnapshot doc) {
    return Transaction(
      monthYear: doc['monthyear'],
      remainingAmount: doc['remainingAmount'].toDouble(),
      totalCredit: doc['totalCredit'].toDouble(),
      totalDebit: doc['totalDebit'].toDouble(),
      timestamp: doc['timestamp'],
    );
  }
}

class BarChartScreen extends StatefulWidget {
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  DateTime currentMonth = DateTime.now();

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
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Biểu đồ tài chính',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('transactions')
                    .where('monthyear',
                    isEqualTo: DateFormat('M/y').format(currentMonth))
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4285F4),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                          SizedBox(height: 16),
                          Text(
                            'Lỗi: ${snapshot.error}',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có giao dịch',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    List<Transaction> transactions = snapshot.data!.docs
                        .map((doc) => Transaction.fromDocument(doc))
                        .toList();

                    // Tạo 1 map để lưu trữ giao dịch mới nhất của mỗi monthYear
                    Map<String, Transaction> latestTransactions = {};
                    for (var transaction in transactions) {
                      if (
                      !latestTransactions.containsKey(transaction.monthYear) ||
                          latestTransactions[transaction.monthYear]!.timestamp.compareTo(transaction.timestamp) < 0
                      ) {
                        latestTransactions[transaction.monthYear] = transaction;
                      }

                    }

                    List<Transaction> combinedTransactionList =
                    latestTransactions.values.toList();
                    combinedTransactionList
                        .sort((a, b) => a.monthYear.compareTo(b.monthYear));

                    double totalCredit = combinedTransactionList.fold(
                        0, (sum, item) => sum + item.totalCredit);
                    double totalDebit = combinedTransactionList.fold(
                        0, (sum, item) => sum + item.totalDebit);
                    double remainingAmount = totalCredit - totalDebit;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      color: Color(0xFF4285F4),
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Tổng thu/chi các tháng gần đây',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 380,
                                child: TransactionBarChart(
                                  data: combinedTransactionList,
                                  currencyFormat: currencyFormat,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem('Khoản thu', Colors.green),
                                    SizedBox(width: 24),
                                    _buildLegendItem('Khoản chi', Colors.red),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: CashFlow(
                            remainingAmount: remainingAmount,
                            totalCredit: totalCredit,
                            totalDebit: totalDebit,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMonthNavigationButton(
                icon: Icons.arrow_back,
                onPressed: previousMonth,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('M/y').format(currentMonth),
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildMonthNavigationButton(
                icon: Icons.arrow_forward,
                onPressed: nextMonth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Color(0xFF4285F4),
        iconSize: 24,
      ),
    );
  }
}

class TransactionBarChart extends StatelessWidget {
  final List<Transaction> data;
  final NumberFormat currencyFormat;

  TransactionBarChart({required this.data, required this.currencyFormat});

  String formatToMillions(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    double maxY = _calculateMaxY();
    // Đảm bảo maxY chia hết cho 2 triệu để các mốc đẹp
    maxY = (maxY / 2000000).ceil() * 2000000;

    return BarChart(
      BarChartData(
        barGroups: _buildBarGroups(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    data[index].monthYear,
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
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
              reservedSize: 40, // Tăng không gian cho số tiền
              interval: 2000000, // Khoảng cách 2 triệu
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxY) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    formatToMillions(value),
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 11,
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2000000, // Grid theo 2 triệu
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String monthYear = data[group.x.toInt()].monthYear;
              String label = rodIndex == 0 ? 'Thu' : 'Chi';
              return BarTooltipItem(
                '$monthYear\n$label',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\n${currencyFormat.format(rod.toY)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {},
        ),
      ),
    );
  }

  double _calculateMaxY() {
    double maxY = 0;
    for (var transaction in data) {
      if (transaction.totalCredit > maxY) maxY = transaction.totalCredit;
      if (transaction.totalDebit > maxY) maxY = transaction.totalDebit;
    }
    return maxY == 0 ? 2000000 : maxY; // Đặt min 2 triệu nếu không có dữ liệu
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      Transaction transaction = entry.value;
      return BarChartGroupData(
        x: index,
        groupVertically: false,
        barRods: [
          BarChartRodData(
            toY: transaction.totalCredit,
            color: Colors.green.shade400,
            width: 15,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(),
              color: Colors.grey.shade100,
            ),
          ),
          BarChartRodData(
            toY: transaction.totalDebit,
            color: Colors.red.shade400,
            width: 15,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(),
              color: Colors.grey.shade100,
            ),
          ),
        ],
        barsSpace: 8,
      );
    }).toList();
  }
}