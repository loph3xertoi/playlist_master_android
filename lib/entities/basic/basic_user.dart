import 'package:flutter/foundation.dart';

@immutable
class BasicUser {
  const BasicUser({
    required this.name,
    required this.headPic,
    required this.bgPic,
  });

  final String name;
  final String headPic;
  final String bgPic;
}
