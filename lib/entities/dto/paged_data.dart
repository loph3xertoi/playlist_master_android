import 'package:flutter/foundation.dart';

/// DTO for paged data.
@immutable
class PagedDataDTO<T> {
  PagedDataDTO(this.count, this.list, this.hasMore);

  /// The total count of target data.
  final int count;

  /// The paged data.
  final List<T>? list;

  /// Whether there has more data.
  final bool hasMore;
}
