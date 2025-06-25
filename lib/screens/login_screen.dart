import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:utmhub/widgets/text_field_input.dart';
import 'package:utmhub/screens/signup_screen.dart';
import 'package:utmhub/screens/home_screen.dart';
import 'package:utmhub/resources/auth_methods.dart';
import 'package:utmhub/screens/forgot_password_screen.dart';
import 'package:utmhub/screens/admin_dashboard.dart';
import 'package:utmhub/services/ban_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _passwordController=TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isError = false;

  @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();//to dispose after using 
  }  // Enhanced login function with admin credential checking
  void loginUser() async {
    // Set loading state and clear any previous error messages
    setState(() {
      _isLoading = true; // Show loading spinner on login button
      _errorMessage = ''; // Clear any previous error messages
      _isError = false; // Reset error state
    });

    // Check for hardcoded admin credentials before attempting Firebase authentication
    // This allows admin access without needing a Firebase user account
    if (_emailController.text == "basil22@gmail.com" && 
        _passwordController.text == "Basil22!!") {
      // Stop loading state since we're not calling Firebase
      setState(() {
        _isLoading = false;
      });
      
      // Navigate directly to admin dashboard instead of home screen
      // pushReplacement removes login screen from navigation stack
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
      return; // Exit function early to prevent normal login flow
    }

    // Normal user login flow using Firebase Authentication
    String res = await AuthMethods().logInUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Stop loading state after Firebase response
    setState(() {
      _isLoading = false;
    });

    // Check if login was successful
    if (res == "success") {
      // Check if the user is banned before proceeding to home screen
      final banStatus = await BanService.checkCurrentUserBanStatus();
      
      if (banStatus['isBanned'] == true) {
        // User is banned, show appropriate message and sign them out
        await FirebaseAuth.instance.signOut();
        
        String banMessage;
        if (banStatus['isPermanent'] == true) {
          banMessage = 'Your account has been permanently suspended.\n\nReason: ${banStatus['banReason']}';
        } else {
          final timeRemaining = BanService.formatBanTimeRemaining(banStatus['remainingMinutes'] ?? 0);
          banMessage = 'Your account is temporarily suspended.\n\nReason: ${banStatus['banReason']}\nTime remaining: $timeRemaining';
        }
        
        // Show ban message dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text(
                'Account Suspended',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(banMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        
        // Set error state for UI feedback
        setState(() {
          _errorMessage = 'Account suspended';
          _isError = true;
        });
        
        return; // Exit function without navigating to home screen
      }
      
      // User is not banned, navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Handle login errors by updating UI state
      setState(() {
        _errorMessage = res; // Set error message from Firebase
        _isError = true; // Mark as error state for UI styling
      });

      // Show error message as a snackbar for user feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res), // Display the actual error message
          backgroundColor: Colors.red, // Red background for error indication
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      //using Safearea to balance the layout
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            width:double.infinity,
            // Removed the fixed height to allow scrolling
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center ,
              children: [
                SizedBox(height: 80), // Fixed space at the top instead of Flexible
                //logo
                SvgPicture.asset('assets/logo.svg',  height: 200), // Slightly smaller logo
                const SizedBox(height: 20),
                
                // Error message (if any)
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: _isError ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                //input email
                TextFieldInput(
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                const SizedBox(
                  height: 24,
                ),
                //password
                TextFieldInput(
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  isPass: true,
                ),
                const SizedBox(
                  height: 24,
                ),
                //login button
                InkWell(

                  //codndition to check which one should be called
                  //also makes sure no double clidk
                  onTap: _isLoading ? null : loginUser,
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
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),                //Extras
                //goes to forgot password page when user clicks on "Forgot password?"
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Forgot password? ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),  // Add extra space at the bottom for keyboard//had overflow error so implementing this
              ],
            )
          ),
        ),
      ),
    );
  }
}