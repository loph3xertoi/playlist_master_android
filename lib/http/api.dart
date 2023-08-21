class API {
  /// Your uid in playlist master server.
  static const uid = '0';

  static const demoMpd = 'http://$host/mpd/c.mpd';

  /// Host of playlist server.
  static const host = '192.168.141.188:8080';
  // static const host = '192.168.8.171:8080';
  // static const host = '192.168.0.114:8080';

  /// Get user information according to [uid] in [platform].
  /// api: GET /user/[uid]?platform=[platform]
  static const user = '/user';

  /// Get detail song according to [songId] in [platform].
  /// api: GET /song/[songId]?platform=[platform]
  static const detailSong = '/song';

  /// Get all similar songs according to [songId] in [platform].
  /// api: GET /similarSongs/[songId]?platform=[platform]
  static const similarSongs = '/similarSongs';

  /// Search songs according to [keywords] in [platform] with [pageNo] and [pageSize].
  /// api: GET /search/song/[keywords]?pageNo=[pageNo]&pageSize=[pageSize]&platform=[platform]
  static const searchSong = '/search/song';

  // /// Get song's link according to [songMid], [mediaMid] and [type] in [platform].
  // /// api: GET /songLink/[songMid]?mediaMid=[mediaMid]&type=[type]&platform=[platform]
  // static const songLink = '/songLink';

  /// Get all songs' link according to [SongIds] in [platform].
  /// api: GET /songsLink/[SongIds]?platform=[platform]
  /// TODO: api need to update for handle flv in bilibili for some resources.
  static const songsLink = '/songsLink';

  /// Get all MVs' links according to [vids] in [platform].
  /// api: GET /mvLink/[vids]?platform=[platform]
  static const mvLink = '/mvLink';

  /// Get detail MV according to [vid] in [platform].
  /// api: GET /mv/[vid]?platform=[platform]
  static const detailMV = '/mv';

  /// Get all related MVs according to [songId] in [platform].
  /// api: GET /relatedMV/[songId]?mvId=[mvId]&limit=[limit]&platform=[platform]
  static const relatedMV = '/relatedMV';

  /// Get all libraries according to [uid] in [platform].
  /// api: GET /libraries?id=[uid]&platform=[platform]
  static const libraries = '/libraries';

  /// Get detail library according to [library] in [platform].
  /// api: GET /library/[library]?platform=[platform]
  static const detailLibrary = '/library';

  /// Create library in [platform] with [name].
  /// api: POST /library?platform=[platform] {'name': [name]}
  static const createLibrary = '/library';

  /// Delete library in [platform] with id [libraries].
  /// api: DELETE /library/[libraries]?platform=[platform]
  static const deleteLibrary = '/library';

  /// Add songs to library with [libraryId] in [platform],
  /// [tid] is used to evict cache.
  /// api: POST /addSongsToLibrary?platform=[platform] {'libraryId':[libraryId],'songsId':[songsId],'tid':[tid]}
  static const addSongsToLibrary = '/addSongsToLibrary';

  /// Move songs from one library to another library in [platform],
  /// [fromTid] and [toTid] is used to evict cache.
  /// api: PUT /moveSongsToOtherLibrary?platform=[platform] {'songsId':[songsId],'fromLibrary':[fromLibrary],
  /// 'toLibrary':[toLibrary], 'fromTid':[fromTid], 'toTid':[toTid]}
  static const moveSongsToOtherLibrary = '/moveSongsToOtherLibrary';

  /// Remove songs from library with [libraryId] in [platform],
  /// [tid] is used to evict cache.
  /// api: DELETE /removeSongsFromLibrary?libraryId=[libraryId]&songsId=[songsId]&platform=[platform]&tid=[tid]
  static const removeSongsFromLibrary = '/removeSongsFromLibrary';

  /// Get bilibili splash screen images.
  /// api: GET /cors/bili/splash
  static const getBiliSplashScreenImage = '/cors/bili/splash';

  /// Get search suggestions in bilibili.
  /// api: GET /cors/bili/suggestions/[keyword]
  static const getSearchSuggestions = '/cors/bili/suggestions';

  /// Get image from pms for cors and referrer reason.
  /// api: GET /cors/image?imageUrl=[imageUrl]
  static const getImage = '/cors/image';

  /// Convert raw image url to image url for pms.
  static String convertImageUrl(String rawImageUrl) {
    return Uri.http(API.host, API.getImage, {'imageUrl': rawImageUrl})
        .toString();
  }
}
