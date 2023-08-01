import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyHttp {
  static DefaultCacheManager defaultCacheManager = DefaultCacheManager();

  static VideoCacheManager videoCacheManager = VideoCacheManager();

  static clearCache() async {
    defaultCacheManager.emptyCache();
    videoCacheManager.emptyCache();
  }
}

class VideoCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'video_cache';

  static final VideoCacheManager _instance = VideoCacheManager._();

  factory VideoCacheManager() {
    return _instance;
  }

  VideoCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}
