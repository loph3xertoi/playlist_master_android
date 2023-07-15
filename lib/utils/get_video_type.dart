class VideoUtil {
  static String? getVideoType(String url) {
    int questionMarkIndex = url.indexOf('?');
    int periodIndex = url.lastIndexOf('.', questionMarkIndex);
    if (questionMarkIndex > periodIndex && periodIndex != -1) {
      String videoType = url.substring(periodIndex + 1, questionMarkIndex);
      return videoType;
    }
    return null;
  }
}
