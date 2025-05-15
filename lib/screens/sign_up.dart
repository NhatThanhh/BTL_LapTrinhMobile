import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validate.dart';
import 'login_screen.dart';

class SignUpView extends StatefulWidget {
  SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  var authService = AuthService();
  var isLoader = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });
      var data = {
        "username": _userNameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "phone": _phoneController.text,
        'remainingAmount': 0,
        'totalCredit': 0,
        'totalDebit': 0
      };

      await authService.createUser(data, context);
      setState(() {
        isLoader = false;
      });
    }
  }

  var appValidator = Validate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA1C4F8), // Xanh dương pastel đậm hơn
              Colors.white,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 60.0),
                  // Icon app
                  Icon(
                    Icons.person_add_alt_1,
                    size: 70,
                    color: Color(0xFF4285F4),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    "Tạo tài khoản mới",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 35.0),
                  // Username field
                  TextFormField(
                    controller: _userNameController,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration("Tài khoản", Icons.person),
                    validator: appValidator.validateUserName,
                  ),
                  SizedBox(height: 16.0),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration("Email", Icons.email),
                    validator: appValidator.validateEmail,
                  ),
                  SizedBox(height: 16.0),
                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration("Số điện thoại", Icons.call),
                    validator: appValidator.validatePhoneNumber,
                  ),
                  SizedBox(height: 16.0),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    decoration: _buildInputDecoration("Mật khẩu", Icons.lock),
                    validator: appValidator.validatePassword,
                  ),
                  SizedBox(height: 40.0),
                  // Signup button
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        isLoader ? print("Đang tải...") : _submitForm();
                      },
                      child: isLoader
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Tạo tài khoản",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1, color: Colors.grey.shade400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Hoặc",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1, color: Colors.grey.shade400)),
                    ],
                  ),
                  SizedBox(height: 25.0),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn đã có tài khoản? ",
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginView()),
                          );
                        },
                        child: Text(
                          "Đăng nhập",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4285F4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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