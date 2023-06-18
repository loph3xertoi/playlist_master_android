import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool isSearching = false;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _heightAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _colorAnimation = ColorTween(
      begin: Colors.amber,
      end: Colors.blue,
    ).animate(_controller);
    _heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 1),
    ).animate(_controller);
    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_controller);
  }

  void _onSearchPressed() {
    setState(() {
      isSearching = true;
    });
    _controller
      ..value = 0
      ..animateTo(1, curve: Curves.fastOutSlowIn)
      ..animateTo(1,
          curve: _CustomCurve(begin: 0.5, end: 1, height: 0.5, strength: 2));
  }

  void _onSearchCanceled() {
    setState(() {
      isSearching = false;
    });
    _controller
      ..value = 1
      ..animateTo(0, curve: Curves.fastOutSlowIn)
      ..animateTo(0,
          curve: _CustomCurve(begin: 0.5, end: 1, height: 0.5, strength: 2));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: isSearching ? TextField() : Text('My App'),
          actions: [
            IconButton(
              icon: isSearching ? Icon(Icons.cancel) : Icon(Icons.search),
              onPressed: isSearching ? _onSearchCanceled : _onSearchPressed,
            ),
          ],
        ),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height *
                      _heightAnimation.value,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Transform.translate(
                    offset: _slideAnimation.value *
                        MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        color: _colorAnimation.value,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Positioned(
                  bottom: -MediaQuery.of(context).size.height *
                      _heightAnimation.value,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: _slideAnimation.value *
                        MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CustomCurve extends Curve {
  final double begin;
  final double end;
  final double height;
  final double strength;

  _CustomCurve({
    required this.begin,
    required this.end,
    required this.height,
    required this.strength,
  });

  @override
  double transformInternal(double t) {
    final double x = (t - begin) / (end - begin);
    final double y = 1 - (1 - pow(x, strength)) * (1 - sin(height * pi / 2));
    return y;
  }
}
