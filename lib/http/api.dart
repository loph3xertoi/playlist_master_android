class API {
  /// Your uid in playlist master server.
  static const uid = '0';

  /// Host of playlist server.
  static const host = '192.168.8.171:8080';
  // static const host = '192.168.0.114:8080';

  /// Get user information according to [uid] in [platform].
  /// api: /user/[uid]?platform=[platform]
  static const user = '/user';

  /// Get detail song according to [songMid] in [platform].
  /// api: /song/[songMid]?platform=[platform]
  static const detailSong = '/song';

  /// Get all similar songs according to [songId] in [platform].
  /// api: /similarsongs/[songId]?platform=[platform]
  static const similarSongs = '/similarsongs';

  /// Get song's link according to [songMid], [mediaMid] and [type] in [platform].
  /// api: /songlink/[songMid]?mediaMid=[mediaMid]&type=[type]&platform=[platform]
  static const songLink = '/songlink';

  /// Get all songs' link according to [songMids] in [platform].
  /// api: /songslink/[songMids]?platform=[platform]
  static const songsLink = '/songslink';

  /// Get detail MV according to [vid] in [platform].
  /// api: /mv/[vid]?platform=[platform]
  static const detailMV = '/mv';

  /// Get all MVs' links according to [vids] in [platform].
  /// api: /mvlink/[vids]?platform=[platform]
  static const mvLink = '/mvlink';

  /// Get all related MVs according to [songId] in [platform].
  /// api: /relatedmv/[songId]?platform=[platform]
  static const relatedMV = '/relatedmv';

  /// Get all libraries according to [uid] in [platform].
  /// api: /libraries?id=[uid]&platform=[platform]
  static const libraries = '/libraries';

  /// Get detail library according to [library] in [platform].
  /// api: /detaillibrary/[library]?platform=[platform]
  static const detailLibrary = '/detaillibrary';
}
