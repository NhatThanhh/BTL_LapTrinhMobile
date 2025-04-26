import 'package:flutter/material.dart';
import 'package:money_management/services/edit_profile_service.dart';
import 'package:money_management/utils/appvalidator.dart';

class EditProfile extends StatefulWidget {
  final int userId;
  final VoidCallback? onDataRestored;
  const EditProfile({super.key, required this.userId, this.onDataRestored});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final EditProfileService _editProfileService = EditProfileService();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    var data = await _editProfileService.getUserData(widget.userId);
    setState(() {
      userData = data;
    });
  }

  void _refreshData(Map<String, dynamic> newData) {
    setState(() {
      userData = newData;
    });
    if (newData['remainingAmount'] == 0 &&
        newData['totalCredit'] == 0 &&
        newData['totalDebit'] == 0) {
      widget.onDataRestored?.call(); // Gọi callback khi dữ liệu được làm mới
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade100,
        title: const Center(
          child: Text(
            "Sửa thông tin cá nhân",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Tài khoản'),
              subtitle: Text(userData!['username'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editProfileService.editField(
                  context,
                  widget.userId,
                  'username',
                  userData!['username'] ?? '',
                  false,
                  _refreshData,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Email'),
              subtitle: Text(userData!['email'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editProfileService.editField(
                  context,
                  widget.userId,
                  'email',
                  userData!['email'] ?? '',
                  false,
                  _refreshData,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Số điện thoại'),
              subtitle: Text(userData!['phone'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editProfileService.editField(
                  context,
                  widget.userId,
                  'phone',
                  userData!['phone'] ?? '',
                  false,
                  _refreshData,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _editProfileService.changePassword(
                context,
                widget.userId,
                _refreshData,
              ),
              child: const Text(
                'Đổi mật khẩu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _editProfileService.restoreData(
                context,
                widget.userId,
                _refreshData,
              ),
              child: const Text(
                'Làm mới dữ liệu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}