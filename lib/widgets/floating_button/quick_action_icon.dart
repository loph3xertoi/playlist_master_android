import 'package:flutter/material.dart';

class QuickActionIcon extends StatelessWidget {
  final String imageUri;
  final Color backgroundColor;
  final double width;
  final double height;

  const QuickActionIcon({
    required this.imageUri,
    required this.backgroundColor,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            imageUri,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
