import 'package:btl_quanlychitieu/screens/transactions/widgets/transaction_list.dart';
import 'package:flutter/material.dart';

class TypeTabBar extends StatefulWidget {
  TypeTabBar({
    Key? key,
    required this.category,
    required this.monthYear,
    required String searchQuery,
  }): searchQuery = searchQuery, super(key: key);

  final String category;
  final String monthYear;
  final String searchQuery;

  @override
  State<TypeTabBar> createState() => _TypeTabBarState();
}

class _TypeTabBarState extends State<TypeTabBar> {
  String currentType = "Tất cả"; // Loại giao dịch hiện tại
  final List<Map<String, String>> typeOptions = [
    {'name': 'Tất cả', 'value': 'all'},
    {'name': 'Thu', 'value': 'credit'},
    {'name': 'Chi', 'value': 'debit'},
  ];

  // Màu pastel blue từ TimeLineMonth
  final Color pastelBlue = const Color(0xFF90CAF9);
  final Color pastelBlueDark = const Color(0xFF64B5F6);

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
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: 300, // Giới hạn chiều cao cho dialog
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
                            Navigator.pop(context);
                          });
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
                              color: isSelected ? pastelBlueDark : Color(0xFF2C3E50),
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

  @override
  Widget build(BuildContext context) {
    // Xác định type cho TransactionList dựa trên currentType
    String transactionType;
    switch (currentType) {
      case 'Thu':
        transactionType = 'credit';
        break;
      case 'Chi':
        transactionType = 'debit';
        break;
      default:
        transactionType = 'all';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 2.0,
      child: Column(
        children: [
          // Nút chọn loại giao dịch
          GestureDetector(
            onTap: () {
              _showTypeDialog(context);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: pastelBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: pastelBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentType,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: pastelBlueDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: pastelBlueDark,
                  ),
                ],
              ),
            ),
          ),
          // Danh sách giao dịch
          Expanded(
            child: TransactionList(
              category: widget.category,
              monthYear: widget.monthYear,
              type: transactionType,
              searchQuery: widget.searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}