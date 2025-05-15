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
      padding: EdgeInsets.all(20.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF4285F4),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Dòng tiền',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoRow(
            'Số dư tài khoản',
            currencyFormat.format(remainingAmount),
            remainingAmount >= 0 ? Color(0xFF2C3E50) : Colors.red,
            Icons.account_balance,
          ),
          Divider(height: 24, color: Colors.grey.shade200),
          _buildInfoRow(
            'Tổng thu',
            currencyFormat.format(totalCredit),
            Colors.green,
            Icons.arrow_downward,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Tổng chi',
            currencyFormat.format(totalDebit),
            Colors.red,
            Icons.arrow_upward,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFEAF2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Color(0xFF4285F4),
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}