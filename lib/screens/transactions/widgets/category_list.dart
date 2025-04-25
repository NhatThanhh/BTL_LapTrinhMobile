import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../utils/icons_list.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  State<CategoryList> createState() => _TimeLineMonthState();
}

class _TimeLineMonthState extends State<CategoryList> {
  String currentCategory = "Tất cả";
  List<Map<String, dynamic>> categoryList = [];

  final scrollController = ScrollController();
  var appIcons = AppIcons();
  var addCat = {
    'name': 'Tất cả',
    'icon': FontAwesomeIcons.cartPlus,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      categoryList = appIcons.homeExpensesCategories;
      categoryList.insert(0, addCat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
          controller: scrollController,
          itemCount: categoryList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var data = categoryList[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  currentCategory = data['name'];
                  widget.onChanged(data['name']);
                });
              },
              child: Container(
                margin: EdgeInsets.all(6),
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    color: currentCategory == data['name']
                        ? Colors.amber
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                    child: Row(
                  children: [
                    Icon(
                      data['icon'],
                      size: 15,
                      color: currentCategory == data['name']
                          ? Colors.black
                          : Colors.blue.shade900,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      data['name'],
                      style: TextStyle(
                        color: currentCategory == data['name']
                            ? Colors.black
                            : Colors.blue.shade900,
                      ),
                    ),
                  ],
                )),
              ),
            );
          }),
    );
  }
}
