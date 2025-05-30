import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:utmhub/resources/auth_methods.dart';
import 'package:utmhub/widgets/text_field_input.dart';
import 'package:utmhub/view/screens/login_screen.dart';
import 'package:flutter/src/painting/image_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Helper method to determine message color based on content
  Color _getMessageColor() {
    if (_errorMessage.contains('successful')) {
      return Colors.green;
    }
    return Colors.red;
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // logo
                SvgPicture.asset(
                  'assets/logo.svg',
                  height: 180,
                ),
            
                const SizedBox(height: 10),                //upload picture
                /*Stack(
                  children: [
                    const CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1610375229632-c7158c35a537?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () {
                          print('Add photo button clicked');
                        },
                        icon: const Icon(Icons.add_a_photo),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),*/
                const SizedBox(height: 24),
                // Username input
                TextFieldInput(
                  hintText: 'Enter your username',
                  textInputType: TextInputType.text,
                  textEditingController: _usernameController,
                ),
                const SizedBox(height: 24),
                // Email input
                TextFieldInput(
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                const SizedBox(height: 24),
                // Password input
                TextFieldInput(
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  isPass: true,
                ),
                const SizedBox(height: 24),
                // Bio input
                TextFieldInput(
                  hintText: 'Enter your bio',
                  textInputType: TextInputType.text,
                  textEditingController: _bioController,
                ),
                const SizedBox(height: 24),                // Error message display
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: _getMessageColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // Sign up Button
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: Color.fromRGBO(224, 167, 34, 1),
                  ),                  
                  child: InkWell(
                    onTap: _isLoading 
                      ? null 
                      : () async {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });
                          
                          // Validate inputs
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              _usernameController.text.isEmpty) {
                            setState(() {
                              _errorMessage = 'Please fill all required fields';
                              _isLoading = false;
                            });
                            return;
                          }
                          
                          try {
                            //  signup logic 
                            print("Sign up button tapped");
                            String res = await AuthMethods().signUpUser(
                              email: _emailController.text, 
                              password: _passwordController.text, 
                              username: _usernameController.text, 
                              bio: _bioController.text,
                            );
                              if (res != 'success') {
                              setState(() {
                                _errorMessage = res;
                                _isLoading = false;
                              });
                            } else {
                              // If signup was successful
                              setState(() {
                                // 
                                _errorMessage = 'Signup successful! Redirecting to login...';
                              });
                              
                              // loadinhg screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Account created successfully!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              
                              // waiting 2 sec, can be changed to longer
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.of(context).pop(); // Navigate back to login screen
                              });
                            }
                          } catch (err) {
                            setState(() {
                              _errorMessage = err.toString();
                              _isLoading = false;
                            });
                          }
                        },
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ) 
                      : const Text(
                          'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 24),

                // Go to login pahe
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40), // extra space at the bottom for keyboard, it was giving an error "bottom overflowed by 115 pixel"
              ],
            ),
          ),
        ),
      ),
    );
  }
}

























/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:utmhub/resources/auth_methods.dart';
import 'package:utmhub/widgets/text_field_input.dart';
import 'package:utmhub/screens/login_screen.dart';
import 'package:flutter/src/painting/image_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();
  bool _isLoading = false;
  String _errorMessage = '';
  Future<void> _handleSignUp() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // Validate inputs
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all required fields';
        _isLoading = false;
      });
      return;
    }
    
    try {
      // Add signup logic here
      print("Sign up button tapped");
      String res = await AuthMethods().signUpUser(
        email: _emailController.text, 
        password: _passwordController.text, 
        username: _usernameController.text, 
        bio: _bioController.text,
      );
      
      if (res != 'success') {
        setState(() {
          _errorMessage = res;
          _isLoading = false;
        });
      } else {
        // Success - navigate to home or login
        Navigator.of(context).pop();
      }
    } catch (err) {
      setState(() {
        _errorMessage = err.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _bioFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // logo
                SvgPicture.asset(
                  'assets/logo.svg',
                  height: 180,
                ),
            
                const SizedBox(height: 10),                //upload picture
                /*Stack(
                  children: [
                    const CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1610375229632-c7158c35a537?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () {
                          print('Add photo button clicked');
                        },
                        icon: const Icon(Icons.add_a_photo),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),*/
                const SizedBox(height: 24),                // Username input
                TextFieldInput(
                  hintText: 'Enter your username',
                  textInputType: TextInputType.text,
                  textEditingController: _usernameController,
                  focusNode: _usernameFocus,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                ),
                const SizedBox(height: 24),
                // Email input
                TextFieldInput(
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                  focusNode: _emailFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                ),
                const SizedBox(height: 24),
                // Password input
                TextFieldInput(
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  focusNode: _passwordFocus,
                  isPass: true,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_bioFocus),
                ),
                const SizedBox(height: 24),
                // Bio input
                TextFieldInput(
                  hintText: 'Enter your bio',
                  textInputType: TextInputType.text,
                  textEditingController: _bioController,
                  focusNode: _bioFocus,
                  textInputAction: TextInputAction.done,                  onSubmitted: (_) => _handleSignUp(),
                ),
                const SizedBox(height: 24),                // Error message display
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: _getMessageColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // Sign up Button
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: Color.fromRGBO(224, 167, 34, 1),
                  ),                    child: InkWell(
                    onTap: _isLoading ? null : _handleSignUp,
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ) 
                      : const Text(
                          'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                // Switch to login
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: "Login",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/