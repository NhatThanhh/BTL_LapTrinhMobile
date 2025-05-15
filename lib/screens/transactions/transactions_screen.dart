import 'package:btl_quanlychitieu/screens/transactions/widgets/category_list.dart';
import 'package:btl_quanlychitieu/screens/transactions/widgets/time_line_month.dart';
import 'package:btl_quanlychitieu/screens/transactions/widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../home/add_transaction_screen/add_transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String category = "Tất cả";
  String monthYear = "";
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String currentType = "Tất cả"; // Loại giao dịch hiện tại

  final List<Map<String, String>> typeOptions = [
    {'name': 'Tất cả', 'value': 'all'},
    {'name': 'Thu', 'value': 'credit'},
    {'name': 'Chi', 'value': 'debit'},
  ];

  // Màu pastel blue từ TimeLineMonth
  final Color pastelBlue = const Color(0xFF90CAF9);
  final Color pastelBlueDark = const Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    monthYear = DateFormat('M/y').format(now);
  }

  // Hiển thị dialog chọn loại giao dịch
  void _showTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 300,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn loại giao dịch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: typeOptions.length,
                    itemBuilder: (context, index) {
                      final type = typeOptions[index];
                      final isSelected = type['name'] == currentType;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentType = type['name']!;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? pastelBlue.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: pastelBlueDark)
                                : null,
                          ),
                          child: Text(
                            type['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? pastelBlueDark : const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dialogBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const AddTransactionForm(),
        );
      },
    );
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
    });
  }

  void _searchTransactions(String query) {
    print("Searching for: $query");
  }

  @override
  Widget build(BuildContext context) {
    // Xác định type cho TransactionList
    final transactionType = switch (currentType) {
      'Thu' => 'credit',
      'Chi' => 'debit',
      _ => 'all',
    };

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogBuilder(context),
        backgroundColor: Colors.blueAccent.shade100,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent.shade100,
        title: isSearching
            ? TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search transactions...",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          onChanged: _searchTransactions,
        )
            : const Text(
          "Giao dịch",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: isSearching ? _stopSearch : _startSearch,
            icon: Icon(isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Cụm tùy chọn tĩnh: TimeLineMonth, CategoryList, nút chọn loại
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TimeLineMonth
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: TimeLineMonth(
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => monthYear = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                // CategoryList
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: CategoryList(
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => category = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                // Nút chọn loại giao dịch
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: GestureDetector(
                    onTap: () => _showTypeDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: pastelBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pastelBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              currentType,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: pastelBlueDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: pastelBlueDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // TransactionList cuộn độc lập
          Expanded(
            child: TransactionList(
              category: category,
              monthYear: monthYear,
              type: transactionType,
            ),
          ),
        ],
      ),
    );
  }
}