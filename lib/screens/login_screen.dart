import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:utmhub/widgets/text_field_input.dart';
import 'package:utmhub/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final TextEditingController _emailController=TextEditingController();
    final TextEditingController _passwordController=TextEditingController();

    @override
    void dispose(){
      super.dispose();
      _emailController.dispose();
      _passwordController.dispose();//to dispose after using 
    }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      //using Safearea to balance the layout
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          width:double.infinity,
           //padding would be from both edge
           child:Column(
            crossAxisAlignment: CrossAxisAlignment.center ,
            children: [
              Flexible(child: Container(),flex: 1), //flex so that its above the login field
              //logo
              SvgPicture.asset('assets/logo.svg',  height: 250,),
              const SizedBox(height: 4),
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
              ),              //login button
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
                  onTap: () {
                    // Add login logic here
                    print("Login button tapped");
                  },
                  child: const Text('Log in'),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(child: Container(), flex: 1),              //Extras
              GestureDetector(
                onTap: (){                  Navigator.push(
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
              )
            ],

           )

        ),
        ),
    );
  }
}