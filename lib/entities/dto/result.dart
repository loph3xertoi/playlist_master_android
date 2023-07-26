import 'package:flutter/material.dart';

@immutable
class Result {
  const Result(this.success, {this.message, this.data, this.total});

  final bool success;
  final String? message;
  final Object? data;
  final int? total;

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      json['success'],
      message: json['message'],
      data: json['data'],
      total: json['total'],
    );
  }
}
