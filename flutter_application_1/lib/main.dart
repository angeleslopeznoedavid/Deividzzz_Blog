import 'package:flutter/material.dart';
import 'screens/add_blog_page.dart';
import 'screens/blog_page.dart';
import 'screens/login_user_page.dart';
import 'screens/profile_page.dart';
import 'screens/recover_password.dart';
import 'screens/register_user_page.dart';
import 'screens/users_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi aplicacion',
      // Primero abre el Login
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/recover': (context) => const RecoverPage(),
        '/users': (context) => const UsersPage(),
        '/blog': (context) => const BlogPage(),
        '/add-blog': (context) => const AddBlogPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
