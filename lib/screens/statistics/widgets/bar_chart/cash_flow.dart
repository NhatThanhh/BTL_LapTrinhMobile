import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashFlow extends StatelessWidget {
  final double remainingAmount;
  final double totalCredit;
  final double totalDebit;

  CashFlow({
    required this.remainingAmount,
    required this.totalCredit,
    required this.totalDebit,
  });

  @override
  Widget build(BuildContext context) {
    NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dòng tiền',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số dư tài khoản',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                currencyFormat.format(remainingAmount),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thu',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              Text(
                currencyFormat.format(totalCredit),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng chi',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              Text(
                currencyFormat.format(totalDebit),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
