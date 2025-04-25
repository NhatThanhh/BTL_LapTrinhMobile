import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcons {
  final List<Map<String, dynamic>> homeExpensesCategories = [
    {
      'name': 'Thuê nhà',
      'icon': FontAwesomeIcons.home,
    },
    {
      'name': 'Tiện ích',
      'icon': FontAwesomeIcons.lightbulb,
    },
    {
      'name': 'Mua sắm',
      'icon': FontAwesomeIcons.shoppingCart,
    },
    {
      'name': 'Phương tiện',
      'icon': FontAwesomeIcons.bus,
    },
    {
      'name': 'Giải trí',
      'icon': FontAwesomeIcons.film,
    },
    {
      'name': 'Chăm sóc sức khỏe',
      'icon': FontAwesomeIcons.heart,
    },
    {
      'name': 'Bảo hiểm',
      'icon': FontAwesomeIcons.shieldHalved,
    },
    {
      'name': 'Tiết kiệm',
      'icon': FontAwesomeIcons.piggyBank,
    },
    {
      'name': 'Ăn uống',
      'icon': FontAwesomeIcons.utensils,
    },
    {
      'name': 'Mua sắm',
      'icon': FontAwesomeIcons.shoppingBag,
    },
    {
      'name': 'Giáo dục',
      'icon': FontAwesomeIcons.graduationCap,
    },
    {
      'name': 'Quà tặng',
      'icon': FontAwesomeIcons.gift,
    },
    {
      'name': 'Du lịch',
      'icon': FontAwesomeIcons.plane,
    },
    {
      'name': 'Nhiên liệu',
      'icon': FontAwesomeIcons.gasPump,
    },
    {
      'name': 'Quần áo',
      'icon': FontAwesomeIcons.tshirt,
    },
    {
      'name': 'Điện tử',
      'icon': FontAwesomeIcons.mobileAlt,
    },
    {
      'name': 'Sách',
      'icon': FontAwesomeIcons.book,
    },
    {
      'name': 'Thể thao',
      'icon': FontAwesomeIcons.footballBall,
    },
    {
      'name': 'Vật nuôi',
      'icon': FontAwesomeIcons.paw,
    },
    {
      'name': 'Từ thiện',
      'icon': FontAwesomeIcons.handsHelping,
    },
    {
      'name': 'Đầu tư',
      'icon': FontAwesomeIcons.chartLine,
    },
    {
      'name': 'Âm nhạc',
      'icon': FontAwesomeIcons.music,
    },
    {
      'name': 'Sở thích',
      'icon': FontAwesomeIcons.paintBrush,
    },
    {
      'name': 'Hóa đơn',
      'icon': FontAwesomeIcons.fileInvoiceDollar,
    },
    {
      'name': 'Phí',
      'icon': FontAwesomeIcons.moneyCheck,
    },
    {
      'name': 'Thuế',
      'icon': FontAwesomeIcons.fileAlt,
    },
    {
      'name': 'Vay mượn',
      'icon': FontAwesomeIcons.handshake,
    },
    {
      'name': 'Chăm sóc trẻ',
      'icon': FontAwesomeIcons.baby,
    },
    {
      'name': 'Sửa nhà',
      'icon': FontAwesomeIcons.hammer,
    },
    {
      'name': 'Phòng tập',
      'icon': FontAwesomeIcons.dumbbell,
    },
    {
      'name': 'Đăng ký',
      'icon': FontAwesomeIcons.creditCard,
    },
    {
      'name': 'Nghệ thuật',
      'icon': FontAwesomeIcons.palette,
    },
    {
      'name': 'Làm đẹp',
      'icon': FontAwesomeIcons.spa,
    },
    {
      'name': 'Vệ sinh',
      'icon': FontAwesomeIcons.broom,
    },
    {
      'name': 'Vé',
      'icon': FontAwesomeIcons.ticketAlt,
    },
    {
      'name': 'Đám cưới',
      'icon': FontAwesomeIcons.ring,
    },
    {
      'name': 'Tiệc tùng',
      'icon': FontAwesomeIcons.cocktail,
    },
    {
      'name': 'Cấp cứu',
      'icon': FontAwesomeIcons.firstAid,
    },
    {
      'name': 'Khác',
      'icon': FontAwesomeIcons.ellipsis,
    },
  ];

  IconData getExpenseCategoryIcons(String categoryName) {
    final category = homeExpensesCategories.firstWhere(
        (category) => category['name'] == categoryName,
        orElse: () => {"icon": FontAwesomeIcons.ellipsis});
    return category['icon'];
  }
}
