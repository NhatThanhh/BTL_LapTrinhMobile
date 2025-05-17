import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onAddButtonPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onAddButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Nút Trang chủ
          _buildNavItem(0, Icons.home_rounded, Icons.home, 'Tổng quan'),

          // Nút Thống kê

          _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Danh sách'),
          // Nút Thêm ở giữa
          InkWell(
            onTap: onAddButtonPressed,
            child: Container(
              height: 65,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),

          // Nút Giao dịch

          _buildNavItem(1, Icons.insert_chart_outlined, Icons.insert_chart_rounded, 'Thống kê'),
          // Nút Trang cá nhân
          _buildNavItem(3, Icons.person_outline, Icons.person_rounded, 'Tài khoản'),
        ],
      ),
    );
  }

  // Widget xây dựng các mục điều hướng
  Widget _buildNavItem(int index, IconData normalIcon, IconData selectedIcon, String label) {
    final bool isSelected = index == selectedIndex;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      child: Container(
        height: 65,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : normalIcon,
              color: isSelected ? Color(0xFF4285F4) : Colors.grey.shade600,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Color(0xFF4285F4) : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}