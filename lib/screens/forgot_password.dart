import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import 'login_screen.dart';
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final authService = LocalAuthService();
  String? _recoveredPassword;

  Future<void> _recoverPassword() async {
    if (_formKey.currentState!.validate()) {
      final user = await authService.getUserByEmailOrPhone(_inputController.text);
      if (user != null) {
        setState(() {
          _recoveredPassword = user.password;
        });
      } else {
        setState(() {
          _recoveredPassword = "Không tìm thấy tài khoản.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E292F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Quên mật khẩu",
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _inputController,
                style: TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("Email hoặc số điện thoại", Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập thông tin.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _recoverPassword,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFCC5311)),
                child: Text("Lấy lại mật khẩu", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              if (_recoveredPassword != null)
                Text(
                  _recoveredPassword!,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFCC5311),
                  side: BorderSide(color: Color(0xFFCC5311)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                label: Text(
                  "Đăng nhập",
                  style: TextStyle(fontSize: 16),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
      fillColor: Color(0xFF414A54),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0D23DA))),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      filled: true,
      labelStyle: TextStyle(color: Color(0xFF949494)),
      labelText: label,
      suffixIcon: Icon(suffixIcon, color: Color(0xFF949494)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}
