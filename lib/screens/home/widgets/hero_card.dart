import 'package:flutter/material.dart';
import 'package:money_management/Models/local_db_service.dart';
import 'package:money_management/models/user_model.dart';

/// Hàm định dạng số tiền VND
String formatCurrency(int amount) {
  return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} ₫';
}

class HeroCard extends StatelessWidget {
  final UserModel user;

  const HeroCard({Key? key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Cards(
        remainingAmount: formatCurrency(user.remainingAmount),
        totalCredit: formatCurrency(user.totalCredit),
        totalDebit: formatCurrency(user.totalDebit),
    );
  }
}

class Cards extends StatelessWidget {
  final String remainingAmount;
  final String totalCredit;
  final String totalDebit;

  const Cards({
    super.key,
    required this.remainingAmount,
    required this.totalCredit,
    required this.totalDebit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.shade100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Số dư tài khoản",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.2,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  remainingAmount,
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      height: 1.2,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              color: Colors.white,
            ),
            child: Row(children: [
              CardOne(
                color: Colors.green,
                heading: 'Thu',
                amount: totalCredit,
              ),
              const SizedBox(width: 10),
              CardOne(
                color: Colors.red,
                heading: 'Chi',
                amount: totalDebit,
              ),
            ]),
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
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(color: color, fontSize: 14),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: color,
                  child: Icon(
                    heading == "Thu"
                        ? Icons.south_east_rounded
                        : Icons.north_east_rounded,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
