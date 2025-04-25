// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:money_management/models/category_model.dart';
// import 'package:money_management/models/local_db_service.dart';
// import 'package:money_management/models/transaction_model.dart';
// import 'package:money_management/utils/icons_list.dart';
// import 'dart:math';
//
// // Lớp tạm để lưu transaction kèm categoryName
// class TransactionModelWithCategory {
//   final TransactionModel transaction;
//   String? categoryName;
//
//   TransactionModelWithCategory({
//     required this.transaction,
//     this.categoryName,
//   });
// }
//
// class PieChartScreen extends StatefulWidget {
//   final int userId;
//   final DateTime currentMonth;
//
//   const PieChartScreen({super.key, required this.userId, required this.currentMonth});
//
//   @override
//   _PieChartScreenState createState() => _PieChartScreenState();
// }
//
// class _PieChartScreenState extends State<PieChartScreen> {
//   String selectedType = 'credit';
//   final appIcons = AppIcons();
//   int? touchedIndex;
//   Map<String, Color> categoryColors = {};
//
//   void _showTransactionDetailsDialog(
//       BuildContext context, List<TransactionModelWithCategory> transactions) {
//     if (transactions.isEmpty) return;
//
//     var categoryName = transactions[0].categoryName ?? 'Unknown';
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Chi tiết: $categoryName'),
//           content: Container(
//             width: double.maxFinite,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Số giao dịch: ${transactions.length}'),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: transactions.length,
//                     itemBuilder: (context, index) {
//                       var transaction = transactions[index];
//                       return Card(
//                         child: ListTile(
//                           leading: Icon(appIcons.getExpenseCategoryIcons(
//                               transaction.categoryName ?? '')),
//                           title: Text('Danh mục: ${transaction.categoryName ?? 'Unknown'}'),
//                           subtitle: Text(
//                             'Số tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.transaction.amount)}',
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Đóng'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<List<TransactionModelWithCategory>> _fetchTransactions(String type, String monthYear) async {
//     final transactions = await LocalDbService.instance.getTransactionsByFilter(
//       userId: widget.userId,
//       type: type,
//       monthYear: monthYear,
//     );
//
//     List<TransactionModelWithCategory> result = [];
//     for (var tx in transactions) {
//       String? categoryName = 'Unknown';
//       if (tx.categoryId != 0) { // Sửa categoryId != null thành categoryId != 0
//         final category = await LocalDbService.instance.getCategoryById(tx.categoryId);
//         categoryName = category?.name ?? 'Unknown';
//       }
//       result.add(TransactionModelWithCategory(
//         transaction: tx,
//         categoryName: categoryName,
//       ));
//     }
//
//     return result;
//   }
//
//   List<Map<String, dynamic>> getTransactionsForCategory(
//       String category, List<TransactionModelWithCategory> transactions) {
//     return transactions
//         .where((tx) => tx.categoryName == category)
//         .map((tx) => {
//       'category': tx.categoryName,
//       'amount': tx.transaction.amount,
//     })
//         .toList();
//   }
//
//   int getTotalTransactionsForCategory(String category, List<TransactionModelWithCategory> transactions) {
//     return transactions.where((tx) => tx.categoryName == category).length;
//   }
//
//   Widget _buildBadgeWidget(String category) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: categoryColors[category] ?? Colors.blue,
//           width: 2,
//         ),
//       ),
//       child: Icon(
//         appIcons.getExpenseCategoryIcons(category),
//         color: categoryColors[category] ?? Colors.blue,
//         size: 18,
//       ),
//     );
//   }
//
//   Map<String, List<Map<String, dynamic>>> processTransactions(
//       List<TransactionModelWithCategory> transactions) {
//     Map<String, Map<String, double>> rawData = {};
//
//     for (var tx in transactions) {
//       String category = tx.categoryName ?? 'Unknown';
//       double amount = tx.transaction.amount.toDouble();
//
//       if (!rawData.containsKey(selectedType)) {
//         rawData[selectedType] = {};
//       }
//
//       if (!rawData[selectedType]!.containsKey(category)) {
//         rawData[selectedType]![category] = 0;
//       }
//
//       rawData[selectedType]![category] = (rawData[selectedType]![category] ?? 0) + amount;
//     }
//
//     Random random = Random(42);
//     Map<String, List<Map<String, dynamic>>> processedData = {};
//
//     double totalAmount = rawData[selectedType]?.values.fold(0.0, (a, b) => a + b) ?? 0;
//
//     if (rawData.containsKey(selectedType)) {
//       List<Map<String, dynamic>> categoryList = [];
//       int index = 0;
//
//       rawData[selectedType]!.forEach((category, value) {
//         double percentage = totalAmount > 0 ? (value / totalAmount * 100) : 0;
//
//         if (!categoryColors.containsKey(category)) {
//           categoryColors[category] = Color.fromRGBO(
//             random.nextInt(200) + 55,
//             random.nextInt(200) + 55,
//             random.nextInt(200) + 55,
//             1,
//           );
//         }
//
//         final sectionData = PieChartSectionData(
//           title: '${percentage.toStringAsFixed(2)}%',
//           value: value,
//           color: categoryColors[category] ?? Colors.blue,
//           titleStyle: const TextStyle(color: Colors.white),
//           titlePositionPercentageOffset: 0.5,
//           badgeWidget: _buildBadgeWidget(category),
//           badgePositionPercentageOffset: 1.0,
//           radius: touchedIndex == index ? 80 : 70,
//         );
//
//         categoryList.add({
//           'section': sectionData,
//           'category': category,
//           'amount': value,
//           'percentage': percentage,
//           'icon': appIcons.getExpenseCategoryIcons(category),
//           'color': categoryColors[category] ?? Colors.blue,
//           'index': index,
//         });
//
//         index++;
//       });
//
//       categoryList.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
//       processedData[selectedType] = categoryList;
//     }
//
//     return processedData;
//   }
//
//   void switchToCredit() {
//     setState(() {
//       selectedType = 'credit';
//       touchedIndex = null;
//     });
//   }
//
//   void switchToDebit() {
//     setState(() {
//       selectedType = 'debit';
//       touchedIndex = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
//     final monthYear = DateFormat('M/y').format(widget.currentMonth);
//
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black, width: 1),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: selectedType == 'credit' ? Colors.blue : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.monetization_on),
//                       color: selectedType == 'credit' ? Colors.white : Colors.black,
//                       onPressed: switchToCredit,
//                       tooltip: 'Hiển thị thu nhập',
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: selectedType == 'debit' ? Colors.blue : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.money_off),
//                       color: selectedType == 'debit' ? Colors.white : Colors.black,
//                       onPressed: switchToDebit,
//                       tooltip: 'Hiển thị chi tiêu',
//                     ),
//                   ),
//                 ],
//               ),
//               FutureBuilder<List<TransactionModelWithCategory>>(
//                 future: _fetchTransactions(selectedType, monthYear),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Padding(
//                       padding: EdgeInsets.all(50.0),
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Lỗi: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Padding(
//                       padding: EdgeInsets.all(50.0),
//                       child: Column(
//                         children: [
//                           Icon(Icons.info_outline, size: 48, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text('Chưa có dữ liệu cho tháng này'),
//                         ],
//                       ),
//                     );
//                   }
//
//                   var transactions = snapshot.data!;
//                   var data = processTransactions(transactions);
//
//                   if (!data.containsKey(selectedType) || data[selectedType]!.isEmpty) {
//                     return const Padding(
//                       padding: EdgeInsets.all(50.0),
//                       child: Text('Không có dữ liệu cho loại này'),
//                     );
//                   }
//
//                   String chartTitle = selectedType == 'credit' ? 'Thu nhập' : 'Chi tiêu';
//                   double totalAmount = transactions.fold(
//                       0, (sum, tx) => sum + tx.transaction.amount.toDouble());
//
//                   return Column(
//                     children: [
//                       Text(
//                         chartTitle,
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Tổng: ${currencyFormat.format(totalAmount)}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: selectedType == 'credit' ? Colors.green : Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       AspectRatio(
//                         aspectRatio: 1.3,
//                         child: PieChart(
//                           PieChartData(
//                             sections: data[selectedType]!.map((e) {
//                               final value = e['section'] as PieChartSectionData;
//                               final itemIndex = e['index'] as int;
//                               return PieChartSectionData(
//                                 title: value.title,
//                                 value: value.value,
//                                 color: value.color,
//                                 titleStyle: value.titleStyle,
//                                 titlePositionPercentageOffset: value.titlePositionPercentageOffset,
//                                 badgeWidget: value.badgeWidget,
//                                 badgePositionPercentageOffset: value.badgePositionPercentageOffset,
//                                 radius: touchedIndex == itemIndex ? 80 : 70,
//                               );
//                             }).toList(),
//                             centerSpaceRadius: 50,
//                             sectionsSpace: 2,
//                             borderData: FlBorderData(
//                               show: true,
//                               border: Border.all(color: Colors.black12, width: 1),
//                             ),
//                             pieTouchData: PieTouchData(
//                               touchCallback: (FlTouchEvent event, pieTouchResponse) {
//                                 if (event is FlTapUpEvent || event is FlTapDownEvent) {
//                                   setState(() {
//                                     touchedIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex;
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ...data[selectedType]!.map((e) {
//                         return GestureDetector(
//                           onTap: () {
//                             var categoryTransactions = transactions
//                                 .where((tx) => tx.categoryName == e['category'])
//                                 .toList();
//                             _showTransactionDetailsDialog(context, categoryTransactions);
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//                             child: Card(
//                               elevation: 3,
//                               shadowColor: (e['color'] as Color).withOpacity(0.3),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 side: BorderSide(
//                                   color: (e['color'] as Color),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: (e['color'] as Color).withOpacity(0.2),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(
//                                         e['icon'] as IconData,
//                                         color: e['color'] as Color,
//                                         size: 24,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             '${e['category']}',
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           Text(
//                                             '${getTotalTransactionsForCategory(e['category'], transactions)} giao dịch',
//                                             style: TextStyle(
//                                               color: Colors.grey[600],
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           currencyFormat.format(e['amount'] as double),
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: selectedType == 'credit' ? Colors.green : Colors.red,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         Text(
//                                           '${(e['percentage'] as double).toStringAsFixed(1)}%',
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       const SizedBox(height: 16),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }