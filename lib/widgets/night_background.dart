import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playlistmaster/widgets/my_side_drawer.dart';

import '../third_lib_change/day_night_switch.dart';

class NightBackground extends StatefulWidget {
  const NightBackground({super.key});
  @override
  NightBackgroundState createState() => NightBackgroundState();
}

class NightBackgroundState extends State<NightBackground>
    with SingleTickerProviderStateMixin {
  final dayColor = Color(0xFFd56352);
  final nightColor = Color(0xFF1e2230);
  bool val = false;
  late AnimationController _controller;
  late Size size;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF414a4c),
      body: AnimatedContainer(
        color: val ? nightColor : dayColor,
        duration: const Duration(milliseconds: 300),
        child: Stack(
          children: <Widget>[
            ..._buildStars(20),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              height: 200,
              child: Opacity(
                opacity: val ? 0 : 1.0,
                child: Image.asset(
                  'assets/images/cloud.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              height: 200,
              child: Image.asset(
                val
                    ? 'assets/images/mountain2_night.png'
                    : 'assets/images/mountain2.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: -10,
              left: 0,
              right: 0,
              height: 140,
              child: Image.asset(
                val
                    ? 'assets/images/mountain_night.png'
                    : 'assets/images/mountain1.png',
                fit: BoxFit.cover,
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: <Widget>[
                    Positioned(
                      bottom: -20,
                      right: 0,
                      left: 0,
                      child: Transform.translate(
                        offset: Offset(50 * _controller.value, 0),
                        child: Opacity(
                          opacity: val ? 0.0 : 0.8,
                          child: Image.asset(
                            'assets/images/cloud2.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      right: 0,
                      left: 0,
                      child: Transform.translate(
                        offset: Offset(100 * _controller.value, 0),
                        child: Opacity(
                          opacity: val ? 0.0 : 0.4,
                          child: Image.asset(
                            'assets/images/cloud3.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // _buildSun(),
            Transform.translate(
              offset: const Offset(160, -360),
              child: _buildSun(),
            ),
            MySideDrawer(),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                height: 50.0,
                width: 80.0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DayNightSwitch(
                    value: val,
                    moonImage: const AssetImage('assets/images/moon.png'),
                    onChanged: (value) {
                      setState(() {
                        val = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // floatingActionButton: Transform.translate(
      //   offset: const Offset(160, -360),
      //   child: _buildSun(),
      // ),
    );
  }

  Widget _buildSun() {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: AnimatedBuilder(
        animation:
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _buildContainer(400 * _controller.value),
              _buildContainer(500 * _controller.value),
              _buildContainer(600 * _controller.value),
              SizedBox(
                width: 256,
                height: 256,
                child: val
                    ? Image.asset('assets/images/moon.png')
                    : const CircleAvatar(
                        backgroundColor: Color(0xFFFDB813),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (val ? Colors.amber[100] : Colors.orangeAccent)
            ?.withOpacity(1 - _controller.value),
      ),
    );
  }

  List<Widget> _buildStars(int starCount) {
    List<Widget> stars = [];
    for (int i = 0; i < starCount; i++) {
      stars.add(_buildStar(top: randomX, left: randomY, val: val));
    }
    return stars;
  }

  double get randomX {
    int maxX = (size.height).toInt();
    return Random().nextInt(maxX).toDouble();
  }

  double get randomY {
    int maxY = (size.width).toInt();
    return Random().nextInt(maxY).toDouble();
  }

  Widget _buildStar({
    double top = 0,
    double left = 0,
    bool val = false,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Opacity(
        opacity: val ? 1 : 0,
        child: const CircleAvatar(
          radius: 2,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
