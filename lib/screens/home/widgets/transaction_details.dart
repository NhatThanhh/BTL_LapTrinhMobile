import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/icons_list.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final dynamic data;

  TransactionDetailsScreen({super.key, required this.data});

  final NumberFormat currencyFormat =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final AppIcons appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(data['timestamp']);
    String formattedDate = DateFormat('dd/MM/yyyy hh:mma').format(date);
    final String formattedAmount = currencyFormat.format(data['amount']);
    final String iconPath = appIcons.getExpenseCategoryIcons('${data['category']}');
    final bool isCredit = data['type'] == 'credit';
    final Color amountColor = isCredit ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Color(0xFFF1F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chi tiết giao dịch',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction title and amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${data['title']}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        fontSize: 26,
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),

            SizedBox(height: 30),

            // Section: Thông tin giao dịch
            Text(
              'Thông tin giao dịch',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            SizedBox(height: 16),

            // Transaction info table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1), // Icon column
                  1: FlexColumnWidth(2), // Title column
                  2: FlexColumnWidth(2), // Value column
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    width: 1,
                    color: Colors.grey.shade200,
                  ),
                ),
                children: [
                  // Danh mục
                  TableRow(
                    children: [
                      // Icon column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            width: 32,
                            height: 32,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.error,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      // Title column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Danh mục',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Value column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '${data['category']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),

                  // Loại
                  TableRow(
                    children: [
                      // Icon column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Icon(
                            Icons.swap_horiz,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // Title column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Loại',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Value column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          isCredit ? 'Thu' : 'Chi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),

                  // Ngày
                  TableRow(
                    children: [
                      // Icon column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Icon(
                            Icons.calendar_today,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // Title column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Ngày',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Value column
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Section: Lựa chọn
            Text(
              'Lựa chọn',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            SizedBox(height: 16),

            // Actions card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Edit button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 28),
                          onPressed: () {
                            // Giữ nguyên chức năng hiện tại
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sửa',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  // Delete button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white, size: 28),
                          onPressed: () {
                            // Giữ nguyên chức năng hiện tại
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Xóa',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}