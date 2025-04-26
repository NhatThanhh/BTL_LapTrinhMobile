import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/models/user_model.dart';
import 'package:money_management/screens/home/widgets/transaction_details.dart';
import '../../../utils/icons_list.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel data;
  final UserModel user;
  TransactionCard({super.key, required this.data, required this.user});

  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final AppIcons appIcons = AppIcons();

  String formatDateTime(int timestamp) {
    final date = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    return DateFormat('d MMM hh:mma').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = formatDateTime(data.timestamp);
    final String formattedAmount = currencyFormat.format(data.amount);
    final String formattedRemaining = currencyFormat.format(user.remainingAmount);
    final bool isCredit = data.type == 'credit';
    final Color amountColor = isCredit ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(data: data),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 10),
                color: Colors.grey.withOpacity(0.09),
                blurRadius: 10.0,
                spreadRadius: 4.0,
              ),
            ],
          ),
          child: ListTile(
            minVerticalPadding: 10,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            leading: FutureBuilder(
              future: LocalDbService.instance.getCategoryById(data.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 70,
                    alignment: Alignment.center,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: amountColor.withOpacity(0.2),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                final category = snapshot.data;
                final categoryName = category?.name ?? 'Khác';
                return Container(
                  width: 70,
                  alignment: Alignment.center,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: amountColor.withOpacity(0.2),
                    ),
                    child: Center(
                      child: FaIcon(
                        appIcons.getExpenseCategoryIcons(categoryName),
                        color: amountColor,
                        size: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${isCredit ? '+' : '-'} $formattedAmount",
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Số dư",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      formattedRemaining,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}