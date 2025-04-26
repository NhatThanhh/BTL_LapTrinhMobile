import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/models/user_model.dart';
import 'cash_flow.dart';

class ChartTransaction {
  final String monthYear;
  final double totalCredit;
  final double totalDebit;

  ChartTransaction({
    required this.monthYear,
    required this.totalCredit,
    required this.totalDebit,
  });
}

class BarChartScreen extends StatefulWidget {
  final int userId;
  final DateTime currentMonth;
  const BarChartScreen({super.key, required this.userId, required this.currentMonth});

  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  late DateTime currentMonth;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    currentMonth = widget.currentMonth;
  }

  @override
  void didUpdateWidget(covariant BarChartScreen oldWidget) {
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

  Future<UserModel?> _fetchUser() async {
    return await LocalDbService.instance.getUserById(widget.userId);
  }

  Future<List<ChartTransaction>> _fetchChartData() async {
    final monthYear = DateFormat('M/y').format(currentMonth);

    final creditTransactions = await LocalDbService.instance.getTransactionsByFilter(
      userId: widget.userId,
      type: 'credit',
      monthYear: monthYear,
    );

    final debitTransactions = await LocalDbService.instance.getTransactionsByFilter(
      userId: widget.userId,
      type: 'debit',
      monthYear: monthYear,
    );

    double totalCredit = creditTransactions.fold(0, (sum, tx) => sum + tx.amount);
    double totalDebit = debitTransactions.fold(0, (sum, tx) => sum + tx.amount);

    final chartData = [
      ChartTransaction(
        monthYear: monthYear,
        totalCredit: totalCredit,
        totalDebit: totalDebit,
      )
    ];

    // Chỉ lấy 2 tháng trước (tổng 3 tháng)
    for (int i = 1; i <= 2; i++) {
      DateTime prevMonth = DateTime(currentMonth.year, currentMonth.month - i, 1);
      String prevMonthYear = DateFormat('M/y').format(prevMonth);

      final prevCreditTxs = await LocalDbService.instance.getTransactionsByFilter(
        userId: widget.userId,
        type: 'credit',
        monthYear: prevMonthYear,
      );

      final prevDebitTxs = await LocalDbService.instance.getTransactionsByFilter(
        userId: widget.userId,
        type: 'debit',
        monthYear: prevMonthYear,
      );

      double prevTotalCredit = prevCreditTxs.fold(0, (sum, tx) => sum + tx.amount);
      double prevTotalDebit = prevDebitTxs.fold(0, (sum, tx) => sum + tx.amount);

      chartData.add(ChartTransaction(
        monthYear: prevMonthYear,
        totalCredit: prevTotalCredit,
        totalDebit: prevTotalDebit,
      ));
    }

    chartData.sort((a, b) => DateFormat('M/y').parse(a.monthYear).compareTo(DateFormat('M/y').parse(b.monthYear)));

    return chartData;
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<UserModel?>(
                future: _fetchUser(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4285F4),
                        ),
                      ),
                    );
                  }
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                          SizedBox(height: 16),
                          Text(
                            'Lỗi: Không tìm thấy người dùng ${widget.userId}',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final user = userSnapshot.data!;
                  print("Đang tạo biểu đồ cho User: ${user.username} (ID: ${user.id})");

                  return FutureBuilder<List<ChartTransaction>>(
                    future: _fetchChartData(),
                    builder: (context, chartSnapshot) {
                      if (chartSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        );
                      }
                      if (chartSnapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Lỗi: ${chartSnapshot.error}',
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                      if (!chartSnapshot.hasData || chartSnapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: Column(
                              children: [
                                Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                                SizedBox(height: 16),
                                Text(
                                  'Chưa có giao dịch nào',
                                  style: TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final chartData = chartSnapshot.data!;
                      print("Bar Chart Data: ${chartData.length} tháng");
                      for (var item in chartData) {
                        print("${item.monthYear}: Thu: ${item.totalCredit}, Chi: ${item.totalDebit}");
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            padding: const EdgeInsets.all(16.0),
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
                                    data: chartData,
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
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: CashFlow(
                              remainingAmount: user.remainingAmount.toDouble(),
                              totalCredit: user.totalCredit.toDouble(),
                              totalDebit: user.totalDebit.toDouble(),
                            ),
                          ),
                        ],
                      );
                    },
                  );
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
  final List<ChartTransaction> data;
  final NumberFormat currencyFormat;

  const TransactionBarChart({super.key, required this.data, required this.currencyFormat});

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
              reservedSize: 60, // Tăng không gian cho số tiền
              interval: 2000000, // Khoảng cách 2 triệu
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxY) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    currencyFormat.format(value),
                    style: TextStyle(
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
      ChartTransaction transaction = entry.value;
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