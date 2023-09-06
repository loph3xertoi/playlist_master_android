import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import '../http/api.dart';
import 'my_logger.dart';
import 'my_toast.dart';

class PMLogin {
  static Future<bool?> checkToken(String token) async {
    final Uri url = Uri.http(API.host, API.checkToken, {'token': token});
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Checking if token is expired...');
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final isExpired = jsonDecode(utf8.decode(response.bodyBytes)) as bool;
        return isExpired;
      } else {
        var errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(errorMsg);
        MyLogger.logger.e(errorMsg);
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
