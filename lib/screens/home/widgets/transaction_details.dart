import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/models/transaction_model.dart';
import '../../../utils/icons_list.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel data;

  TransactionDetailsScreen({super.key, required this.data});

  final AppIcons appIcons = AppIcons();

  // Hàm định dạng tiền tệ
  String formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} ₫';
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = data.date;
    String formattedDate = DateFormat('dd/MM/yyyy hh:mma').format(date);

    return Scaffold(
      backgroundColor: Color(0xFFF1F7FF), // Màu nền nhẹ như trong hình mẫu
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
            FutureBuilder(
              future: LocalDbService.instance.getCategoryById(data.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Text('Không tìm thấy danh mục');
                }

                final category = snapshot.data!;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 26, // Tăng kích thước chữ
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          formatCurrency(data.amount),
                          style: TextStyle(
                            fontSize: 26, // Tăng kích thước chữ
                            color: data.type == 'credit' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 30), // Tăng khoảng cách

            // Section: Thông tin giao dịch
            Text(
              'Thông tin giao dịch',
              style: TextStyle(
                fontSize: 22, // Tăng kích thước chữ
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            SizedBox(height: 16),

            // Transaction info table
            FutureBuilder(
              future: LocalDbService.instance.getCategoryById(data.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Text('Không tìm thấy danh mục');
                }

                final category = snapshot.data!;

                // Sử dụng bảng thay vì ListTile để hiển thị rõ ràng hơn
                return Container(
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
                                appIcons.getExpenseCategoryIcons(category.name),
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) => const Icon(
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
                                fontSize: 18, // Tăng kích thước chữ
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Value column
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 18, // Tăng kích thước chữ
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
                              data.type == 'credit' ? 'Thu' : 'Chi',
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
                );
              },
            ),

            SizedBox(height: 30), // Tăng khoảng cách

            // Section: Lựa chọn
            Text(
              'Lựa chọn',
              style: TextStyle(
                fontSize: 22, // Tăng kích thước chữ
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
                        radius: 35, // Tăng kích thước nút
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 28),
                          onPressed: () {
                            // TODO: Thêm logic sửa giao dịch (giữ nguyên TODO này)
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sửa',
                        style: TextStyle(fontSize: 18), // Tăng kích thước chữ
                      ),
                    ],
                  ),

                  // Delete button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 35, // Tăng kích thước nút
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white, size: 28),
                          onPressed: () {
                            // TODO: Thêm logic xóa giao dịch (giữ nguyên TODO này)
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Xóa',
                        style: TextStyle(fontSize: 18), // Tăng kích thước chữ
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