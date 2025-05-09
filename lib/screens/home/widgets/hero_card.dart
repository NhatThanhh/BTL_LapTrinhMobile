import 'package:flutter/material.dart';
import 'package:money_management/Models/local_db_service.dart';
import 'package:money_management/models/user_model.dart';
import 'package:intl/intl.dart';

/// Hàm định dạng số tiền VND mới, sử dụng NumberFormat để xử lý tốt hơn
String formatCurrency(int amount) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(amount)} ₫';
}

class HeroCard extends StatelessWidget {
  final UserModel user;

  const HeroCard({Key? key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Cards(
      remainingAmount: user.remainingAmount,
      totalCredit: user.totalCredit,
      totalDebit: user.totalDebit,
    );
  }
}

class Cards extends StatelessWidget {
  final int remainingAmount;
  final int totalCredit;
  final int totalDebit;

  const Cards({
    super.key,
    required this.remainingAmount,
    required this.totalCredit,
    required this.totalDebit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent.shade100,  // Thay màu đầu tiên trong colors bằng backgroundColor
            Colors.blueAccent.shade100,  // Thay màu thứ hai trong colors bằng backgroundColor
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Số dư tài khoản",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency(remainingAmount),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: Colors.white,
            ),
            child: Row(
              children: [
                CardOne(
                  color: Colors.green,
                  heading: 'Thu',
                  amount: totalCredit,
                ),
                const SizedBox(width: 12),
                CardOne(
                  color: Colors.red,
                  heading: 'Chi',
                  amount: totalDebit,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CardOne extends StatelessWidget {
  const CardOne({
    super.key,
    required this.color,
    required this.heading,
    required this.amount,
  });

  final Color color;
  final String heading;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Sử dụng AutoSizeText để tự động thay đổi kích thước chữ
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCurrency(amount),
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  heading == "Thu"
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}