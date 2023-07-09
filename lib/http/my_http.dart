import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyHttp {
  // For image cache.
  static DefaultCacheManager defaultCacheManager = DefaultCacheManager();

  static MVLinkCacheManager mvLinkCacheManager = MVLinkCacheManager();

  static SongsLinkCacheManager songsLinkCacheManager = SongsLinkCacheManager();

  static SongLinkCacheManager songLinkCacheManager = SongLinkCacheManager();

  static DetailPlaylistOtherCacheManager detailPlaylistOtherCacheManager =
      DetailPlaylistOtherCacheManager();

  static VideoCacheManager videoCacheManager = VideoCacheManager();

  static DetailSongOtherCacheManager detailSongOtherCacheManager =
      DetailSongOtherCacheManager();

  static DetailMVOtherCacheManager detailMVOtherCacheManager =
      DetailMVOtherCacheManager();

  static UserOtherCacheManager userOtherCacheManager = UserOtherCacheManager();

  static PlaylistsOtherCacheManager playlistsOtherCacheManager =
      PlaylistsOtherCacheManager();

  static clearCache() async {
    await defaultCacheManager.emptyCache();
    await mvLinkCacheManager.emptyCache();
    await songsLinkCacheManager.emptyCache();
    await songLinkCacheManager.emptyCache();
    await detailPlaylistOtherCacheManager.emptyCache();
    await videoCacheManager.emptyCache();
    await detailSongOtherCacheManager.emptyCache();
    await detailMVOtherCacheManager.emptyCache();
    await userOtherCacheManager.emptyCache();
    await playlistsOtherCacheManager.emptyCache();
  }
}

class MVLinkCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'link_cache/mv';

  static final MVLinkCacheManager _instance = MVLinkCacheManager._();

  factory MVLinkCacheManager() {
    return _instance;
  }

  MVLinkCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}

class SongsLinkCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'link_cache/songs';

  static final SongsLinkCacheManager _instance = SongsLinkCacheManager._();

  factory SongsLinkCacheManager() {
    return _instance;
  }

  SongsLinkCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}

class SongLinkCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'link_cache/song';

  static final SongLinkCacheManager _instance = SongLinkCacheManager._();

  factory SongLinkCacheManager() {
    return _instance;
  }

  SongLinkCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}

class DetailPlaylistOtherCacheManager extends CacheManager
    with ImageCacheManager {
  static const key = 'other_cache/detail_playlist';

  static final DetailPlaylistOtherCacheManager _instance =
      DetailPlaylistOtherCacheManager._();

  factory DetailPlaylistOtherCacheManager() {
    return _instance;
  }

  DetailPlaylistOtherCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
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

class DetailSongOtherCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'other_cache/detail_song';

  static final DetailSongOtherCacheManager _instance =
      DetailSongOtherCacheManager._();

  factory DetailSongOtherCacheManager() {
    return _instance;
  }

  DetailSongOtherCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}

class DetailMVOtherCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'other_cache/detail_mv';

  static final DetailMVOtherCacheManager _instance =
      DetailMVOtherCacheManager._();

  factory DetailMVOtherCacheManager() {
    return _instance;
  }

  DetailMVOtherCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}

class UserOtherCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'other_cache/user';

  static final UserOtherCacheManager _instance = UserOtherCacheManager._();

  factory UserOtherCacheManager() {
    return _instance;
  }

  UserOtherCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}

class PlaylistsOtherCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'other_cache/playlists';

  static final PlaylistsOtherCacheManager _instance =
      PlaylistsOtherCacheManager._();

  factory PlaylistsOtherCacheManager() {
    return _instance;
  }

  PlaylistsOtherCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 7),
        ));
}
