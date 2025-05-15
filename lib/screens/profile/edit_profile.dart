import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/edit_profile_service.dart';
import '../../utils/validate.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var authService = AuthService();

  User? user;
  Map<String, dynamic>? userData;

  var appValidator = Validate();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final EditProfileService _editProfileService = EditProfileService();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    user = await _editProfileService.getCurrentUser();
    if (user != null) {
      var data = await _editProfileService.getUserData(user!);
      setState(() {
        userData = data;
      });
    }
  }

  void _refreshData(Map<String, dynamic> newData) {
    setState(() {
      userData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade100,
        title: Center(
          child: Text("Sửa thông tin cá nhân",
              style: TextStyle(color: Colors.white)),
        ),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Tài khoản'),
                    subtitle: Text(userData!['username'] ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editProfileService.editField(
                          context,
                          user!,
                          'username',
                          userData!['username'] ?? '',
                          false,
                          _refreshData),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Email'),
                    subtitle: Text(userData!['email'] ?? ''),
                  ),
                  Divider(),
                  SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(Icons.call),
                    title: Text('Số điện thoại'),
                    subtitle: Text(userData!['phone'] ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editProfileService.editField(
                          context,
                          user!,
                          'phone',
                          userData!['phone'] ?? '',
                          false,
                          _refreshData),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _editProfileService.changePassword(
                        context, user!, _refreshData),
                    child: const Text(
                      'Đổi mật khẩu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _editProfileService.restoreData(
                        context, user!, _refreshData),
                    child: Text(
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
