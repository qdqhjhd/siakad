import 'package:flutter/material.dart';
import '../pages/login_page.dart';

void logout(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );
}
