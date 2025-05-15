import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  bool _isLoading = false;

  static const _primaryColor = Color(0xFF4285F4);
  static const _gradientColors = [Color(0xFF91C4F8), Colors.white];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _recoverPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final input = _inputController.text.trim();

    try {
      if (input.contains('@')) {
        await _handleEmailReset(input);
      } else {
        await _handlePhoneReset(input);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('Authentication error: ${e.message}');
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    _showSuccessDialog('Password reset email sent to $email');
  }

  Future<void> _handlePhoneReset(String phone) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      _showErrorDialog('No account found with this phone number.');
      return;
    }

    final userData = querySnapshot.docs.first.data();
    final email = userData['email'] as String?;

    if (email == null || email.isEmpty) {
      _showErrorDialog('Invalid email associated with this account.');
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    _showSuccessDialog('Password reset email sent to $email');
  }

  void _showSuccessDialog(String message) {
    _showDialog(message, Colors.green);
  }

  void _showErrorDialog(String message) {
    _showDialog(message, Colors.red);
  }

  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: _buildFormContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        _buildHeaderIcon(),
        const SizedBox(height: 20),
        _buildTitle(),
        const SizedBox(height: 10),
        _buildSubtitle(),
        const SizedBox(height: 40),
        _buildInputField(),
        const SizedBox(height: 25),
        _buildSubmitButton(),
        const Spacer(),
        _buildLoginButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeaderIcon() {
    return const Icon(
      Icons.lock_reset,
      size: 70,
      color: _primaryColor,
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Forgot Password',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter your email or phone number to reset password',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 15,
      ),
    );
  }

  Widget _buildInputField() {
    return TextFormField(
      controller: _inputController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Email or Phone Number',
        prefixIcon: const Icon(Icons.person, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email or phone number';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _recoverPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton.icon(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>LoginView()),
      ),
      icon: const Icon(Icons.arrow_back, color: _primaryColor),
      label: const Text(
        'Back to Login',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }
}