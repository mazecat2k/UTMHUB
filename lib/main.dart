import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:utmhub/responsive/mobile_screen_layout.dart';
import 'package:utmhub/responsive/responsive_layout_screen.dart';
import 'package:utmhub/responsive/web_screen_layout.dart';
import 'package:utmhub/screens/login_screen.dart';
import 'package:utmhub/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:utmhub/utils/ad_manager.dart'; // Import AdManager

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  if(kIsWeb){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: 'AIzaSyDSFTi33sVczR0XwkDQoKBFiGaG8jzX61c',
      appId: '1:390547022585:android:01421a6880797489aef828', 
      messagingSenderId: '390547022585', 
      projectId: 'utmhub-fb',
      storageBucket:'', ),
    );
  }
  else{
    // if condition to check the platform we are on
    await Firebase.initializeApp(); // this is only for android app for now
  }
  
  // Initialize AdMob after Firebase
  await AdManager.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of our application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //hiding the debug icon
      title: 'UTMHub',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
     // home: const ResponsiveLayout(webScreenlayout: WebScreenLayout(), mobileScreenLayout: MobileScreenLayout(),
     home: LoginScreen(),
      );
    //);
  }
}

