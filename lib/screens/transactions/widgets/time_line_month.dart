import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeLineMonth extends StatefulWidget {
  const TimeLineMonth({super.key, required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  State<TimeLineMonth> createState() => _TimeLineMonthState();
}

class _TimeLineMonthState extends State<TimeLineMonth> {
  String currentMonth = "";
  List<String> months = [];
  bool isExpanded = false;

  // Màu blue pastel
  final Color pastelBlue = const Color(0xFF90CAF9);
  final Color pastelBlueDark = const Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    for (int i = -12; i <= 0; i++) {
      months.add(DateFormat('M/y').format(DateTime(now.year, now.month + i, 1)));
    }
    currentMonth = DateFormat('M/y').format(now);
  }
  // Định dạng tháng
  String formatMonthDisplay(String monthStr) {
    try {
      List<String> parts = monthStr.split('/');
      if (parts.length == 2) {
        int month = int.parse(parts[0]);
        int year = int.parse(parts[1]);

        // Chuyển đổi số tháng thành tên tháng tiếng Việt
        String monthName;
        switch (month) {
          case 1: monthName = '1'; break;
          case 2: monthName = '2'; break;
          case 3: monthName = '3'; break;
          case 4: monthName = '4'; break;
          case 5: monthName = '5'; break;
          case 6: monthName = '6'; break;
          case 7: monthName = '7'; break;
          case 8: monthName = '8'; break;
          case 9: monthName = '9'; break;
          case 10: monthName = '10'; break;
          case 11: monthName = '11'; break;
          case 12: monthName = '12'; break;
          default: monthName = '$month';
        }

        return '$monthName/$year';
      }
    } catch (e) {
      print('Error formatting month: $e');
    }
    return monthStr;
  }

  // Hiển thị dialog chọn tháng với grid view
  void _showMonthGridDialog(BuildContext context) {
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
              // Giới hạn chiều cao cho khoảng 5 hàng (mỗi hàng khoảng 80 điểm ảnh)
              maxHeight: 5 * 80 + 100, // 100 cho phần tiêu đề và nút hủy
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn tháng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 tháng mỗi hàng
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5, // Tỷ lệ chiều rộng/chiều cao
                    ),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final isSelected = month == currentMonth;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentMonth = month;
                            widget.onChanged(month);
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? pastelBlue
                                : pastelBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(color: pastelBlueDark)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              formatMonthDisplay(month),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.black : pastelBlueDark,
                              ),
                              textAlign: TextAlign.center,
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
    // Hiển thị nút chọn tháng
    return GestureDetector(
      onTap: () {
        _showMonthGridDialog(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              formatMonthDisplay(currentMonth),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: pastelBlueDark,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: pastelBlueDark,
            ),
          ],
        ),
      ),
    );
  }
}