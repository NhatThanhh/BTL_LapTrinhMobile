import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeroCard extends StatelessWidget {
  HeroCard({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> _usersStream =
    FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    return StreamBuilder<DocumentSnapshot>(
      stream: _usersStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Đã xảy ra lỗi khi tải dữ liệu',
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
          );
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Không tìm thấy dữ liệu người dùng",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: Colors.blueAccent.shade100,
                strokeWidth: 3,
              ),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return Cards(
          data: data,
        );
      },
    );
  }
}

class Cards extends StatelessWidget {
  const Cards({
    super.key,
    required this.data,
  });

  final Map data;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    double totalCredit = data['totalCredit'] is double
        ? data['totalCredit']
        : (data['totalCredit'] as num).toDouble();

    double totalDebit = data['totalDebit'] is double
        ? data['totalDebit']
        : (data['totalDebit'] as num).toDouble();

    double remainingAmount = data['remainingAmount'] is double
        ? data['remainingAmount']
        : (data['remainingAmount'] as num).toDouble();

    // Tìm giá trị lớn nhất để làm mốc cho biểu đồ
    double maxValue = totalCredit > totalDebit ? totalCredit : totalDebit;
    maxValue = maxValue > 0 ? maxValue : 1; // Tránh chia cho 0

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phần hiển thị số dư tài khoản
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 12), // Khoảng cách giữa badge và thông tin số dư

                // Icon và thông tin số dư ở giữa
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Số dư hiện tại",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currencyFormat.format(remainingAmount),
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Phần hiển thị biểu đồ thu chi
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Biểu đồ cột ngang cho Thu
                Row(
                  children: [
                    // Icon và nhãn "Thu"
                    Container(
                      width: 80,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Thu",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Giá trị thu
                    Container(
                      width: 80,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currencyFormat.format(totalCredit),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Thanh biểu đồ cột ngang Thu
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 20,
                          child: Row(
                            children: [
                              Container(
                                width: (MediaQuery.of(context).size.width - 230) * (totalCredit / maxValue),
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Biểu đồ cột ngang cho Chi
                Row(
                  children: [
                    // Icon và nhãn "Chi"
                    Container(
                      width: 80,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.trending_down,
                              color: Colors.red,
                              size: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Chi",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Giá trị chi
                    Container(
                      width: 80,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currencyFormat.format(totalDebit),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Thanh biểu đồ cột ngang Chi
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 20,
                          child: Row(
                            children: [
                              Container(
                                width: (MediaQuery.of(context).size.width - 230) * (totalDebit / maxValue),
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}