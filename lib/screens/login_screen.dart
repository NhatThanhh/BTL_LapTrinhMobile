import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import '../utils/appvalidator.dart';
import '../models/user_model.dart';
import 'sign_up.dart';
import 'forgot_password.dart';
import 'package:money_management/screens/home/home_screen.dart';
import 'package:money_management/Models/local_db_service.dart';
import 'package:money_management/screens/dashboard.dart';

class LoginView extends StatefulWidget {
  LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var authService = LocalAuthService();
  var appValidator = AppValidator();
  var isLoader = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      // Đăng nhập với email và password
      var isLoggedIn = await authService.login(
        _emailController.text,
        _passwordController.text,
        context,
      );

      if (isLoggedIn) {
        // Lấy lại thông tin user từ database để lấy ID
        final loggedInUser = await LocalDbService().getUserByEmail(_emailController.text);

        if (loggedInUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard(userId: loggedInUser.id!)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy người dùng.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại, vui lòng thử lại!')),
        );
      }

      setState(() {
        isLoader = false;
      });
    }
  }


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
              Color(0xFF91C4F8), // Xanh dương pastel
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
                  SizedBox(height: 80.0),
                  // Logo hoặc icon
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Color(0xFF4285F4),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Đăng nhập",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: _buildInputDecoration("Email", Icons.email),
                    validator: appValidator.validateEmail,
                  ),
                  SizedBox(height: 20.0),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    decoration: _buildInputDecoration("Mật khẩu", Icons.lock),
                    validator: appValidator.validatePassword,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordView()),
                        );
                      },
                      child: Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  // Đăng nhập button
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
                        "Đăng nhập",
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
                  SizedBox(height: 20.0),
                  // Google login button
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onPressed: () async {
                        // Google login logic
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 24,
                            child: Image.asset(
                              'assets/images/google.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Đăng nhập bằng Google",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  // Signup link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn là người sử dụng mới? ",
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpView()),
                          );
                        },
                        child: Text(
                          "Đăng ký",
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

  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      prefixIcon: Icon(suffixIcon, color: Color(0xFF4285F4)),
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