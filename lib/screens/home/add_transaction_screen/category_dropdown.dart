import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/icons_list.dart';

class CategoryDropdown extends StatelessWidget {
  CategoryDropdown({super.key, this.cattype, required this.onChanged});

  final String? cattype;
  final ValueChanged<String?> onChanged;
  var appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: cattype,
        isExpanded: true,
        hint: Text("Chọn loại"),
        items: appIcons.homeExpensesCategories
            .map((e) => DropdownMenuItem<String>(
                value: e['name'],
                child: Row(
                  children: [
                    Icon(e['icon'], color: Colors.black26),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      e['name'],
                      style: TextStyle(color: Colors.black26),
                    ),
                  ],
                )))
            .toList(),
        onChanged: onChanged);
  }
}
