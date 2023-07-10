class API {
  /// Your uid, such as qq number.
  static const uid = '2804161589';

  /// Host of playlist server.
  static const host = '192.168.8.171:8080';
  // static const host = '192.168.0.114:8080';

  /// api: /playlists/{uid}/{platformId}
  static const playlists = '/playlists';

  /// api: /songs/{playlistId}/{platformId}
  static const detailPlaylist = '/detailplaylist';

  /// api: /song/{songMid}/{platformId}
  static const detailSong = '/song';

  /// api: /songlink/{platformId}?songMid={songMid}&mediaMid={mediaMid}&type={type}
  static const songLink = '/songlink';

  /// api: /songslink/{platformId}?songMids={songMids}
  static const songsLink = '/songslink';

  /// api: /mv/{vid}/{platformId}
  static const mvDetail = '/mv';

  /// api: /mvlink/{platformId}?vids={vids}
  static const mvsLink = '/mvlink';

  /// api: /user/{uid}
  static const user = '/user';

  /// api: /similarsongs/{songId}/{platformId}
  static const similarSongs = '/similarsongs';
}
