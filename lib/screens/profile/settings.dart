import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedFontStyle = 'aBeeZee';
  bool _darkMode = false;
  String _selectedCurrency = '₫-VND';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent.shade100,
        title: Center(
          child: Text("Cài đặt", style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.text_fields),
              title: Text('Kiểu chữ'),
              subtitle: DropdownButtonFormField<String>(
                value: _selectedFontStyle,
                items:
                    <String>['aBeeZee', 'Roboto', 'Lato'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFontStyle = newValue!;
                  });
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Chế độ tối'),
              subtitle: Text(_darkMode ? 'ON' : 'OFF'),
              trailing: Switch(
                value: _darkMode,
                onChanged: (bool value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.currency_exchange),
              title: Text('Tiền tệ'),
              subtitle: DropdownButtonFormField<String>(
                value: _selectedCurrency,
                items: <String>['₫-VND', '₹-INR', '\$-USD', '€-EUR']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
