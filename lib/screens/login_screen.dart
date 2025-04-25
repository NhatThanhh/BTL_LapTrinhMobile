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
      backgroundColor: Color(0xFF1E292F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50.0),
                SizedBox(
                  width: 250,
                  child: Text(
                    "Đăng nhập",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 40.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.white),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Email", Icons.email),
                  validator: appValidator.validateEmail,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
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
                      "Quên mật khẩu",
                      style: TextStyle(fontSize: 14, color: Color(0xFFCC5311)), // Nhỏ hơn
                    ),
                  ),
                ),

                SizedBox(height: 40.0),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCC5311)),
                    onPressed: () {
                      isLoader ? print("Đang tải...") : _submitForm();
                    },
                    child: isLoader
                        ? Center(child: CircularProgressIndicator())
                        : Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Divider(thickness: 1, color: Colors.grey),
                    Container(
                      color: Color(0xFF1E292F),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "Hoặc",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade100,
                    ),
                    onPressed: () async {
                    },
                    child: isLoader
                        ? Center(child: CircularProgressIndicator())
                        : Row(
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
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bạn là người sử dụng mới? ",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpView()),
                        );
                      },
                      child: Text(
                        "Đăng ký",
                        style:
                        TextStyle(fontSize: 16, color: Color(0xFFCC5311)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
      fillColor: Color(0xFF414A54),
      enabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0D23DA))),
      focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      filled: true,
      labelStyle: TextStyle(color: Color(0xFF949494)),
      labelText: label,
      suffixIcon: Icon(suffixIcon, color: Color(0xFF949494)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}
