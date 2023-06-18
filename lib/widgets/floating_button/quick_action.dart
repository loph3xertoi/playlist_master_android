import 'package:flutter/material.dart';

class QuickAction {
  final String imageUri;
  final Color backgroundColor;
  final Color? iconColor;
  final Function() onTap;

  const QuickAction({
    required this.imageUri,
    this.backgroundColor = Colors.white,
    this.iconColor,
    required this.onTap,
  });
}
