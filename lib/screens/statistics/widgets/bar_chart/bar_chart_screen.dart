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
    setState() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }
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

    for (int i = 1; i <= 5; i++) {
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Biểu đồ tài chính',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<UserModel?>(
              future: _fetchUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Lỗi: Không tìm thấy người dùng ${widget.userId}'),
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
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (chartSnapshot.hasError) {
                      return Center(child: Text('Lỗi: ${chartSnapshot.error}'));
                    }
                    if (!chartSnapshot.hasData || chartSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Column(
                            children: [
                              Icon(Icons.info_outline, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Chưa có giao dịch nào'),
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
                          margin: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Tổng thu/chi các tháng gần đây',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 400,
                                child: TransactionBarChart(
                                  data: chartData,
                                  currencyFormat: currencyFormat,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
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

class TransactionBarChart extends StatelessWidget {
  final List<ChartTransaction> data;
  final NumberFormat currencyFormat;

  const TransactionBarChart({super.key, required this.data, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    double maxY = _calculateMaxY();

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
                    style: const TextStyle(color: Colors.black, fontSize: 10),
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
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String monthYear = data[group.x.toInt()].monthYear;
              String label = rodIndex == 0 ? 'Thu' : 'Chi';
              return BarTooltipItem(
                '$monthYear\n$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: currencyFormat.format(rod.toY),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
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
    return maxY == 0 ? 1000000 : maxY;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      ChartTransaction transaction = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: transaction.totalCredit,
            color: Colors.green,
            width: 16,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: transaction.totalDebit,
            color: Colors.red,
            width: 16,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }).toList();
  }
}