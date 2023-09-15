import 'dart:math';

class StringUtils {
  /// Extract raw title of bili resource with <em> tag to its final title.
  static String extractWholeName(String rawName) {
    RegExp htmlTagsRegex = RegExp(r'<[^>]*>');
    return rawName.replaceAll(htmlTagsRegex, '');
  }

  /// Get random string for state parameter in oauth2.
  static String generateRandomString(int length) {
    const String charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random.secure();
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      int randomIndex = random.nextInt(charset.length);
      buffer.write(charset[randomIndex]);
    }

    return buffer.toString();
  }
}
