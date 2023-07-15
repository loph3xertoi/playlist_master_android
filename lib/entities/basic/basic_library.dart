import 'package:flutter/foundation.dart';

@immutable
class BasicLibrary {
  const BasicLibrary({
    required this.name,
    required this.cover,
    required this.itemCount,
  });

  final String name;
  final String cover;
  final int itemCount;
}
