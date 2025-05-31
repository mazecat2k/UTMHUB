import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:utmhub/view/screens/home_screen.dart';
import 'package:utmhub/view/screens/login_screen.dart';
import 'package:utmhub/view/screens/signup_screen.dart';
import 'package:utmhub/view/screens/forgot_password_screen.dart';
import 'package:utmhub/core/utils/colors.dart';
import 'package:utmhub/repository/post_repo.dart';
import 'package:utmhub/repository/auth_repo.dart';
import 'package:utmhub/repository/comment_repo.dart';
import 'package:utmhub/repository/report_repo.dart';
import 'package:utmhub/viewmodels/post_viewmodel.dart';
import 'package:utmhub/viewmodels/auth_viewmodel.dart';
import 'package:utmhub/viewmodels/comment_viewmodel.dart';
import 'package:utmhub/viewmodels/report_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDSFTi33sVczR0XwkDQoKBFiGaG8jzX61c',
        appId: '1:390547022585:android:01421a6880797489aef828', 
        messagingSenderId: '390547022585', 
        projectId: 'utmhub-fb',
        storageBucket: 'utmhub-fb.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  // Initialize Repositories
  final firestore = FirebaseFirestore.instance;
  final postRepo = PostRepository(firestore);
  final authRepo = AuthRepository();
  final commentRepo = CommentRepository(firestore);
    final reportRepo = ReportRepository(firestore);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => PostViewModel(postRepo, authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentViewModel(commentRepo, authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportViewModel(reportRepo, authRepo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTMHub',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
        primaryColor: const Color.fromRGBO(224, 167, 34, 1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(224, 167, 34, 1),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(224, 167, 34, 1),
        ),
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return authVM.isLoggedIn 
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}