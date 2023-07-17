class API {
  /// Your uid in playlist master server.
  static const uid = '0';

  /// Host of playlist server.
  static const host = '192.168.8.171:8080';
  // static const host = '192.168.0.114:8080';

  /// Get user information according to [uid] in [platform].
  /// api: GET /user/[uid]?platform=[platform]
  static const user = '/user';

  /// Get detail song according to [songMid] in [platform].
  /// api: GET /song/[songMid]?platform=[platform]
  static const detailSong = '/song';

  /// Get all similar songs according to [songId] in [platform].
  /// api: GET /similarSongs/[songId]?platform=[platform]
  static const similarSongs = '/similarSongs';

  /// Get song's link according to [songMid], [mediaMid] and [type] in [platform].
  /// api: GET /songLink/[songMid]?mediaMid=[mediaMid]&type=[type]&platform=[platform]
  static const songLink = '/songLink';

  /// Get all songs' link according to [songMids] in [platform].
  /// api: GET /songsLink/[songMids]?platform=[platform]
  static const songsLink = '/songsLink';

  /// Get all MVs' links according to [vids] in [platform].
  /// api: GET /mvLink/[vids]?platform=[platform]
  static const mvLink = '/mvLink';

  /// Get detail MV according to [vid] in [platform].
  /// api: GET /mv/[vid]?platform=[platform]
  static const detailMV = '/mv';

  /// Get all related MVs according to [songId] in [platform].
  /// api: GET /relatedMV/[songId]?platform=[platform]
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

  /// Delete library in [platform] with id [library].
  /// api: DELETE /library/[library]?platform=[platform]
  static const deleteLibrary = '/library';

  /// Search songs according to [name] in [platform] with [pageNo] and [pageSize].
  /// api: GET /search/song/[name]?pageNo=[pageNo]&pageSize=[pageSize]&platform=[platform]
  static const searchSong = '/search/song';
}
