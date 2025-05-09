import 'package:flutter/material.dart';
import '../../../utils/icons_list.dart';

class CategoryDropdown extends StatelessWidget {
  CategoryDropdown({super.key, this.cattype, required this.onChanged});

  final String? cattype;
  final ValueChanged<String?> onChanged;
  final AppIcons appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showCategoryGrid(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  if (cattype != null)
                    Image.asset(
                      appIcons.getExpenseCategoryIcons(cattype!),
                      width: 24,
                      height: 24,
                      // Bỏ color để hiển thị màu gốc của icon
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    cattype ?? 'Chọn loại',
                    style: TextStyle(
                      color: cattype != null ? Colors.black : Colors.grey,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

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
              maxHeight: MediaQuery.of(context).size.height * 0.8, // Sửa: Giới hạn chiều cao dialog
            ),
            child: SingleChildScrollView( // Sửa: Thêm cuộn dọc
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4, // Sửa: Chiều cao cố định cho GridView
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(), // Sửa: Cho phép cuộn trong GridView
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 icon/hàng
                        crossAxisSpacing: 8, // Giữ 8 để tránh overflow ngang
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8, // Giữ 0.8 để ô cân đối
                      ),
                      itemCount: appIcons.homeExpensesCategories.length,
                      itemBuilder: (context, index) {
                        final category = appIcons.homeExpensesCategories[index];
                        final name = category['name'] as String;
                        final iconPath = category['icon'] as String;
                        final isSelected = name == cattype;

                        return GestureDetector(
                          onTap: () {
                            print("Selected category: $name");
                            onChanged(name);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  iconPath,
                                  width: 24,
                                  height: 24,
                                  // Bỏ color để hiển thị màu gốc của icon
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2C3E50),
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