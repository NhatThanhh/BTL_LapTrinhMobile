import 'package:flutter/material.dart';

class TypeTabBar extends StatelessWidget {
  final String category;
  final String monthYear;
  final String searchQuery;

  const TypeTabBar({
    Key? key,
    required this.category,
    required this.monthYear,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(

      child: Column(
        children: [

        ],
      ),
    );
  }
}
