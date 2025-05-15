import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcons {
  final List<Map<String, dynamic>> homeExpensesCategories = [
    {
      'name': 'Thuê nhà',
      'icon': 'assets/icons/house.png',
    },
    {
      'name': 'Tiện ích',
      'icon': 'assets/icons/idea.png',
    },
    {
      'name': 'Mua sắm',
      'icon': 'assets/icons/trolley.png',
    },
    {
      'name': 'Phương tiện',
      'icon': 'assets/icons/bus.png',
    },
    {
      'name': 'Giải trí',
      'icon': 'assets/icons/cinema.png',
    },
    {
      'name': 'Chăm sóc sức khỏe',
      'icon': 'assets/icons/healthcare.png',
    },
    {
      'name': 'Bảo hiểm',
      'icon': 'assets/icons/safety.png',
    },
    {
      'name': 'Tiết kiệm',
      'icon': 'assets/icons/saving.png',
    },
    {
      'name': 'Ăn uống',
      'icon': 'assets/icons/eat.png',
    },
    {
      'name': 'Giáo dục',
      'icon': 'assets/icons/graduation.png',
    },
    {
      'name': 'Quà tặng',
      'icon': 'assets/icons/giftbox.png',
    },
    {
      'name': 'Du lịch',
      'icon': 'assets/icons/plane.png',
    },
    {
      'name': 'Nhiên liệu',
      'icon': 'assets/icons/fuel.png',
    },
    {
      'name': 'Quần áo',
      'icon': 'assets/icons/shirt.png',
    },
    {
      'name': 'Điện tử',
      'icon': 'assets/icons/smartphone.png',
    },
    {
      'name': 'Sách',
      'icon': 'assets/icons/stack-of-books.png',
    },
    {
      'name': 'Thể thao',
      'icon': 'assets/icons/basketball.png',
    },
    {
      'name': 'Vật nuôi',
      'icon': 'assets/icons/pets.png',
    },
    {
      'name': 'Từ thiện',
      'icon': 'assets/icons/love.png',
    },
    {
      'name': 'Đầu tư',
      'icon': 'assets/icons/growth.png',
    },
    {
      'name': 'Hóa đơn',
      'icon': 'assets/icons/bill.png',
    },
    {
      'name': 'Vay mượn',
      'icon': 'assets/icons/salary.png',
    },
    {
      'name': 'Chăm sóc trẻ',
      'icon': 'assets/icons/baby.png',
    },
    {
      'name': 'Sửa nhà',
      'icon': 'assets/icons/housee.png',
    },
    {
      'name': 'Phòng tập',
      'icon': 'assets/icons/gym.png',
    },
    {
      'name': 'Làm đẹp',
      'icon': 'assets/icons/massage.png',
    },
    {
      'name': 'Vệ sinh',
      'icon': 'assets/icons/broom.png',
    },
    {
      'name': 'Đám cưới',
      'icon': 'assets/icons/couple.png',
    },
    {
      'name': 'Tiệc tùng',
      'icon': 'assets/icons/party-popper.png',
    },
    {
      'name': 'Khác',
      'icon': 'assets/icons/ellipsis.png',
    },
  ];

  String getExpenseCategoryIcons(String categoryName) {
    final category = homeExpensesCategories.firstWhere(
          (category) => category['name'] == categoryName,
      orElse: () => {'icon': 'assets/icons/default.png'},
    );
    return category['icon'] as String;
  }
}
