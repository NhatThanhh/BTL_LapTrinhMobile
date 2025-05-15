import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../../utils/icons_list.dart';

class PieChartScreen extends StatefulWidget {
  @override
  _PieChartScreenState createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  late String userId;
  String selectedType = 'credit';
  var appIcons = AppIcons();
  DateTime currentMonth = DateTime.now();
  int? touchedIndex;
  Map<String, Color> categoryColors = {};

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _showTransactionDetailsDialog(
      BuildContext context, List<Map<String, dynamic>> transactions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var category = transactions[0]['category'];
        return AlertDialog(
          title: Text('Chi tiết: $category'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Số giao dịch: ${transactions.length}'),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      String iconPath = appIcons.getExpenseCategoryIcons(transaction['category']);
                      return Card(
                        child: ListTile(
                          leading: Image.asset(
                            iconPath,
                            width: 24,
                            height: 24,
                          ),
                          title: Text('Danh mục: ${transaction['category']}'),
                          subtitle: Text(
                            'Số tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction['amount'])}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
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

  // Thêm một hàm để lọc transactions theo category và type
  List<Map<String, dynamic>> getTransactionsForCategory(
      String category, String type, QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((data) => data['category'] == category && data['type'] == type)
        .toList();
  }

  int getTotalTransactionsForCategory(
      String category, String type, QuerySnapshot snapshot) {
    return getTransactionsForCategory(category, type, snapshot).length;
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> processTransactions(
      QuerySnapshot snapshot) {
    Map<String, Map<String, Map<String, double>>> rawData = {};

    snapshot.docs.forEach((doc) {
      var data = doc.data() as Map<String, dynamic>;
      String type = data['type'];
      String category = data['category'];
      double amount = data['amount'].toDouble();
      String monthYear = data['monthyear'];

      if (!rawData.containsKey(monthYear)) {
        rawData[monthYear] = {'credit': {}, 'debit': {}};
      }

      if (!rawData[monthYear]![type]!.containsKey(category)) {
        rawData[monthYear]![type]![category] = 0;
      }

      rawData[monthYear]![type]![category] =
          rawData[monthYear]![type]![category]! + amount;
    });

    Random random = Random();

    return rawData.map((monthYear, typeData) {
      double totalCredit = typeData['credit']!.values.fold(0, (a, b) => a + b);
      double totalDebit = typeData['debit']!.values.fold(0, (a, b) => a + b);

      return MapEntry(
        monthYear,
        typeData.map((type, categoryData) {
          double totalAmount = type == 'credit' ? totalCredit : totalDebit;

          List<Map<String, dynamic>> categoryList = [];
          int index = 0;

          categoryData.forEach((category, value) {
            double percentage = value / totalAmount * 100;
            String iconPath = appIcons.getExpenseCategoryIcons(category);

            // Kiểm tra nếu màu đã được tạo cho danh mục này chưa
            if (!categoryColors.containsKey(category)) {
              categoryColors[category] = Color.fromRGBO(
                random.nextInt(256),
                random.nextInt(256),
                random.nextInt(256),
                1,
              );
            }

            categoryList.add({
              'section': PieChartSectionData(
                title: '${percentage.toStringAsFixed(2)}%',
                value: value,
                color: categoryColors[category],
                titleStyle: TextStyle(color: Colors.white),
                titlePositionPercentageOffset: 0.5,
                badgeWidget: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: categoryColors[category]!,
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 18,
                    height: 18,
                    color: categoryColors[category],
                  ),
                ),
                badgePositionPercentageOffset: 1.0,
                radius: touchedIndex == index ? 80 : 70,
              ),
              'category': category,
              'amount': value,
              'percentage': percentage,
              'iconPath': iconPath,
              'color': categoryColors[category],
              'index': index,
            });

            index++;
          });
          return MapEntry(type, categoryList);
        }),
      );
    });
  }

  void switchToCredit() {
    setState(() {
      selectedType = 'credit';
    });
  }

  void switchToDebit() {
    setState(() {
      selectedType = 'debit';
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Biểu đồ chia theo danh mục',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedType == 'credit'
                        ? Colors.amber
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.monetization_on),
                    color:
                    selectedType == 'credit' ? Colors.white : Colors.black,
                    onPressed: switchToCredit,
                    tooltip: 'Hiển thị biểu đồ thanh toán',
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedType == 'debit'
                        ? Colors.amber
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.money_off),
                    color:
                    selectedType == 'debit' ? Colors.white : Colors.black,
                    onPressed: switchToDebit,
                    tooltip: 'Hiển thị biểu đồ thu nhập',
                  ),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('transactions')
                  .where('monthyear',
                  isEqualTo: DateFormat('M/y').format(currentMonth))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Chưa có dữ liệu cho tháng này'));
                }

                var data = processTransactions(snapshot.data!);
                String currentMonthString =
                DateFormat('M/y').format(currentMonth);

                if (!data.containsKey(currentMonthString) ||
                    !data[currentMonthString]!.containsKey(selectedType) ||
                    data[currentMonthString]![selectedType]!.isEmpty) {
                  return Center(child: Text('Không có dữ liệu cho loại này'));
                }

                String chartTitle =
                selectedType == 'credit' ? 'Thu nhập' : 'Thanh toán';

                return Column(
                  children: [
                    Text('$chartTitle', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections:
                          data[currentMonthString]![selectedType]!.map((e) {
                            final value = e['section'] as PieChartSectionData;
                            final itemIndex = e['index'] as int;
                            return PieChartSectionData(
                              title: value.title,
                              value: value.value,
                              color: value.color,
                              titleStyle: value.titleStyle,
                              titlePositionPercentageOffset:
                              value.titlePositionPercentageOffset,
                              badgeWidget: value.badgeWidget,
                              badgePositionPercentageOffset:
                              value.badgePositionPercentageOffset,
                              radius: touchedIndex == itemIndex ? 80 : 70,
                            );
                          }).toList(),
                          centerSpaceRadius: 50,
                          sectionsSpace: 2,
                          borderData: FlBorderData(show: false),
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              if (event is FlTapUpEvent ||
                                  event is FlTapDownEvent) {
                                setState(() {
                                  touchedIndex = pieTouchResponse
                                      ?.touchedSection?.touchedSectionIndex;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ...data[currentMonthString]![selectedType]!.map((e) {
                      return GestureDetector(
                        onTap: () {
                          var transactions = getTransactionsForCategory(
                              e['category'], selectedType, snapshot.data!);
                          _showTransactionDetailsDialog(context, transactions);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: (e['color'] as Color).withOpacity(0.1),
                            child: Center(
                              child: ListTile(
                                leading: Image.asset(
                                  e['iconPath'] as String,
                                  width: 24,
                                  height: 24,
                                  color: e['color'] as Color,
                                ),
                                title: Text(
                                  '${e['category']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Số tiền: ${currencyFormat.format(e['amount'] as double)}',
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Chiếm: ${(e['percentage'] as double).toStringAsFixed(2)}%',
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Số giao dịch: ${getTotalTransactionsForCategory(e['category'], selectedType, snapshot.data!)}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
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
              icon: Icon(Icons.arrow_back),
              color: Colors.blueAccent,
            ),
            Text(
              DateFormat('M/y').format(currentMonth),
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: nextMonth,
              icon: Icon(Icons.arrow_forward),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}