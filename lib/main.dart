import 'package:flutter/material.dart';
import 'screens/signin.dart';
import 'screens/home.dart';
import 'screens/signup.dart';
import 'screens/profile/infor.dart';
import 'screens/categories.dart';
import 'screens/list.dart';
import 'screens/list_job/jobs.dart';
import 'screens/detail_job/detail.dart';

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
        '/home': (context) => HomeScreen(),
        '/signup': (context) => SignUp(),
        '/profile': (context) => ProfilePage(),
        '/categories': (context) => JobCategoryScreen(),
        '/list': (context) => JobListPage(),
        '/search': (context) => ListJobScreen(),
        '/detail': (context) => DetailJob(),
      },
    );
  }
}
