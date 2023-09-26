import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import '../http/api.dart';
import 'my_logger.dart';
import 'my_toast.dart';

class PMLogin {
  static Future<bool?> checkIfLogin(String token) async {
    final Uri url = Uri.https(API.host, API.check);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Checking login state...');
      final response = await client.get(url, headers: {'Cookie': token});
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        var errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(errorMsg);
        MyLogger.logger.w(errorMsg);
        return false;
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
