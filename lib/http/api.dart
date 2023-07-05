class API {
  /// Your uid, such as qq number.
  static const uid = '2804161589';

  /// Host of playlist server.
  static const host = '192.168.8.171:8080';
  // static const host = '192.168.0.114:8080';

  /// api: /playlists/{uid}/{platformId}
  static const playlists = '/playlists';

  /// api: /songs/{playlistId}/{platformId}
  static const detailPlaylist = '/songs';

  /// api: /song/{songMid}/{platformId}
  static const detailSong = '/song';

  /// api: /songlink/{platformId}
  static const songlink = '/songlink';

  /// api: /user/{uid}
  static const user = '/user';
}
