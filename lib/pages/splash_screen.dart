import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/');
    });
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/welcome.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
