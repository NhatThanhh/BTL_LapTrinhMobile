import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar(
      {super.key,
        required this.selectedIndex,
        required this.onDestinationSelected});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -3),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: NavigationBar(
        onDestinationSelected: onDestinationSelected,
        indicatorColor: Color(0xFFE6F0FF), // Màu xanh dương pastel nhạt
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 65, // Chiều cao phù hợp
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Color(0xFF4285F4)),
            icon: Icon(Icons.home_outlined, color: Colors.grey.shade600),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF4285F4)),
            icon: Icon(Icons.bar_chart_outlined, color: Colors.grey.shade600),
            label: 'Thống kê',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.edit_note, color: Color(0xFF4285F4)),
            icon: Icon(Icons.edit_note_outlined, color: Colors.grey.shade600),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_2, color: Color(0xFF4285F4)),
            icon: Icon(Icons.person_2_outlined, color: Colors.grey.shade600),
            label: 'Trang cá nhân',
          ),
        ],
      ),
    );
  }
}