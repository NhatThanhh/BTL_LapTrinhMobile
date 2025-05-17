import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../utils/icons_list.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  String currentCategory = "Tất cả";
  List<Map<String, dynamic>> categoryList = [];

  final AppIcons appIcons = AppIcons();

  // Màu pastel blue từ TimeLineMonth
  final Color pastelBlue = const Color(0xFF90CAF9);
  final Color pastelBlueDark = const Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    setState(() {
      categoryList = appIcons.homeExpensesCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Center(
        child: GestureDetector(
          onTap: () {
            _showCategoryGrid(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: pastelBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pastelBlue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hiển thị icon của danh mục hiện tại
                currentCategory != "Tất cả"
                    ? Image.asset(
                  appIcons.getExpenseCategoryIcons(currentCategory),
                  width: 16,
                  height: 16,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      FontAwesomeIcons.cartPlus,
                      size: 16,
                      color: pastelBlueDark,
                    );
                  },
                )
                    : Icon(
                  FontAwesomeIcons.cartPlus,
                  size: 16,
                  color: pastelBlueDark,
                ),
                SizedBox(width: 8),
                // Hiển thị tên danh mục hiện tại
                Text(
                  currentCategory,
                  style: TextStyle(
                    color: pastelBlueDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: pastelBlueDark,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hiển thị dialog cho phép chọn danh mục dạng grid view
  void _showCategoryGrid(BuildContext context) {
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
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn danh mục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Thêm nút "Tất cả" vào đầu danh sách
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentCategory = "Tất cả";
                        widget.onChanged("Tất cả");
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: "Tất cả" == currentCategory
                            ? pastelBlue.withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: "Tất cả" == currentCategory
                            ? Border.all(color: pastelBlueDark)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.cartPlus,
                            size: 20,
                            color: "Tất cả" == currentCategory
                                ? Colors.black
                                : Color(0xFF2C3E50),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Tất cả",
                            style: TextStyle(
                              fontSize: 16,
                              color: "Tất cả" == currentCategory
                                  ? Colors.black
                                  : Color(0xFF2C3E50),
                              fontWeight: "Tất cả" == currentCategory
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 24),
                  // GridView cho các danh mục khác
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 item mỗi hàng
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8, // Tỷ lệ chiều rộng/chiều cao
                      ),
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        final category = categoryList[index];
                        final name = category['name'] as String;
                        final iconPath = category['icon'] as String;
                        final isSelected = name == currentCategory;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentCategory = name;
                              widget.onChanged(name);
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? pastelBlue.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: pastelBlueDark)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  iconPath,
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.error,
                                      size: 24,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.black : Color(0xFF2C3E50),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
          ),
        );
      },
    );
  }
}