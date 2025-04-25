import 'package:flutter/material.dart';
import 'package:money_management/screens/login_screen.dart';
import '../models/user_model.dart';
import '../Models/local_db_service.dart';

class LocalAuthService {
  final dbService = LocalDbService();

  Future<void> createUser(UserModel user, BuildContext context) async {
    final existingUser = await dbService.getUserByEmail(user.email);
    if (existingUser != null) {
      _showErrorDialog(context, "Đăng ký thất bại", "Email đã được sử dụng");
      return;
    }

    await dbService.insertUser(user);

    // Sau khi thành công, hiển thị dialog rồi chuyển sang login
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Đăng ký thành công"),
        content: Text("Vui lòng đăng nhập lại"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginView()),
              );// Đóng dialog
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }



  Future<bool> login(String email, String password, BuildContext context) async {
    // Thực hiện kiểm tra đăng nhập, ví dụ với SQLite hoặc Firebase

    // Nếu đăng nhập thành công, trả về true
    bool isLoggedIn = false;

    try {
      // Giả sử kiểm tra login thành công
      final user = await LocalDbService().getUserByEmail(email);

      if (user != null && user.password == password) {
        isLoggedIn = true;
      }
    } catch (e) {
      print("Lỗi đăng nhập: $e");
    }

    return isLoggedIn;
  }
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  Future<UserModel?> getUserByEmailOrPhone(String input) async {
    return await dbService.getUserByEmail(input);
  }
  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
