import 'package:flutter/material.dart';

@immutable
class Result {
  const Result(this.success, {this.errorMsg, this.data, this.total});

  final bool success;
  final String? errorMsg;
  final Object? data;
  final int? total;
}
