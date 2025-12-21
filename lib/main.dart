import 'package:flutter/material.dart';
import 'screens/signin.dart';
import 'screens/home.dart';
import 'screens/signup.dart';
import 'screens/infor.dart';
import 'screens/categories.dart';
import 'screens/list.dart';
import 'screens/jobs.dart';
import 'screens/detail.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => SignIn(),
        '/home': (context) => MyWidget(),
        '/signup': (context) => SignUp(),
        '/profile': (context) => ProfilePage(),
        '/categories': (context) => JobCategoryPage(),
        '/list': (context) =>JobListPage(),
        '/search': (context) =>ListJob(),
        '/detail': (context) =>DetailJob(),
      },
    );
  }
}