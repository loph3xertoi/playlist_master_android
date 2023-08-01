import 'package:flutter/material.dart';

class LevelBar extends StatelessWidget {
  const LevelBar({
    required this.proportion,
    required this.activeColor,
    required this.inactiveColor,
    required this.height,
    required this.width,
    this.radius = 2.0,
  }) : assert(proportion >= 0 && proportion <= 1,
            'proportion must between 0.0 and 1.0');

  final double proportion;
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: inactiveColor,
          ),
        ),
        Container(
          height: height,
          width: proportion * width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: activeColor,
          ),
        ),
      ],
    );
  }
}
