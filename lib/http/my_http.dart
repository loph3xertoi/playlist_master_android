import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyHttp {
  // static DefaultCacheManager defaultCacheManager = DefaultCacheManager();

  static MyImageCacheManager myImageCacheManager = MyImageCacheManager();

  static VideoCacheManager videoCacheManager = VideoCacheManager();

  static clearCache() async {
    // defaultCacheManager.emptyCache();
    myImageCacheManager.emptyCache();
    videoCacheManager.emptyCache();
  }
}

class MyImageCacheManager extends CacheManager {
  static const key = 'image_cache';

  static final MyImageCacheManager _instance = MyImageCacheManager._();

  factory MyImageCacheManager() {
    return _instance;
  }

  MyImageCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(minutes: 20),
        ));
}

class VideoCacheManager extends CacheManager {
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
