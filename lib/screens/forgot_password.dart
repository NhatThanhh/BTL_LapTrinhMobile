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
  bool _isLoading = false;

  Future<void> _recoverPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF91C4F8), // Xanh dương pastel
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  // Icon
                  Icon(
                    Icons.lock_reset,
                    size: 70,
                    color: Color(0xFF4285F4),
                  ),
                  SizedBox(height: 20),
                  // Tiêu đề
                  Text(
                    "Quên mật khẩu",
                    style: TextStyle(
                        fontSize: 28,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10),
                  // Mô tả
                  Text(
                    "Nhập email hoặc số điện thoại để lấy lại mật khẩu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Input field
                  TextFormField(
                    controller: _inputController,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                    decoration: _buildInputDecoration("Email hoặc số điện thoại", Icons.person),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập thông tin.";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 25),
                  // Button lấy lại mật khẩu
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _recoverPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                          "Lấy lại mật khẩu",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  // Hiển thị mật khẩu đã tìm thấy
                  if (_recoveredPassword != null)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _recoveredPassword!.startsWith("Không")
                                ? "Kết quả"
                                : "Mật khẩu của bạn",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4285F4),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _recoveredPassword!,
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 18,
                              fontWeight: _recoveredPassword!.startsWith("Không")
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  Spacer(),
                  // Button quay lại đăng nhập
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                      );
                    },
                    icon: Icon(Icons.arrow_back, color: Color(0xFF4285F4)),
                    label: Text(
                      "Quay lại đăng nhập",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      prefixIcon: Icon(prefixIcon, color: Color(0xFF4285F4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Color(0xFF4285F4), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2.0),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }
}