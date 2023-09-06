import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login Page',
        ),
      ),
      body: Column(
        children: [
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.apple)),
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.google)),
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.microsoft)),
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.github)),
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.email)),
          IconButton(onPressed: () {}, icon: Icon(Icons.phone_android_rounded)),
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.twitter)),
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.reddit)),
          IconButton(onPressed: () {}, icon: Icon(MdiIcons.facebook)),
        ],
      ),
    );
  }
}
