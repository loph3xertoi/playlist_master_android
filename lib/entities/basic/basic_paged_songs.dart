import 'package:flutter/foundation.dart';

@immutable
class BasicPagedSongs {
  const BasicPagedSongs({
    required this.pageNo,
    required this.pageSize,
    required this.total,
  });

  /// Page number.
  final int pageNo;

  /// Page size.
  final int pageSize;

  /// Total numbers of all matched songs.
  final int total;
}
