import 'dart:math' as math;

import 'package:flutter/material.dart';

///
///  create by zmtzawqlp on 2019/5/27
///
num degToRad(num deg) => deg * (math.pi / 180.0);

num radToDeg(num rad) => rad * (180.0 / math.pi);

double mapValueFromRangeToRange(double value, double fromLow, double fromHigh,
    double toLow, double toHigh) {
  return toLow + ((value - fromLow) / (fromHigh - fromLow) * (toHigh - toLow));
}

double clamp(double value, double low, double high) {
  return math.min(math.max(value, low), high);
}

Widget defaultWidgetBuilder(bool isLiked, double size) {
  return Icon(
    isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
    color: isLiked ? Color(0xFFFC2D2D) : Color(0x42000000),
    size: size,
  );
}
