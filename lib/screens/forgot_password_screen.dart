//interface created, doesn't work, need to integrate fully with the firebase 

import 'package:flutter/material.dart';
import 'package:utmhub/widgets/text_field_input.dart';
import 'package:utmhub/resources/auth_methods.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _isError = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _message = 'Please enter your email';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // Using AuthMethods to reset password
      String res = await AuthMethods().resetPassword(
        email: _emailController.text.trim(),
      );
      
      setState(() {
        _isLoading = false;
        _message = res;
        _isError = res != "Password reset link sent to your email";
      });
      
      // Show message 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
          backgroundColor: _isError ? Colors.red : Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = e.toString();
        _isError = true;
      });
      
      // Show error messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                
                const Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Enter your email and we will send you a password reset link',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Error/Success message (if any)
                if (_message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _isError ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // Email input
                TextFieldInput(
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                
                const SizedBox(height: 40),
                
                // Reset button
                InkWell(
                  onTap: _isLoading ? null : _resetPassword,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      color: Color.fromRGBO(224, 167, 34, 1),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
