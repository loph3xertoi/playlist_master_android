import 'package:flutter/foundation.dart';

import '../basic/basic_song.dart';
import 'qqmusic_lyrics.dart';
import 'qqmusic_singer.dart';

/// Detail song of qq music.
@immutable
class QQMusicDetailSong extends BasicSong {
  const QQMusicDetailSong(
      this.subTitle,
      this.albumName,
      this.songId,
      this.songMid,
      this.mediaMid,
      this.duration,
      this.songDesc,
      this.pubTime,
      this.lyrics,
      this.pmPlaylists,
      this.size128,
      this.size320,
      this.sizeApe,
      this.sizeFlac,
      {required super.name,
      required super.singers,
      required super.cover,
      required super.payPlay,
      required super.isTakenDown,
      required super.songLink});

  /// The sub title of the song.
  final String subTitle;

  /// The name of the album.
  final String albumName;

  /// The id of the song.
  final String songId;

  /// The mid of the song.
  final String songMid;

  /// The media mid of the song.
  final String mediaMid;

  /// The duration of the song.
  final int duration;

  /// The description of the song.
  final String songDesc;

  /// The release time of this song
  final String pubTime;

  /// PMSSong's lyrics.
  final QQMusicLyrics lyrics;

  /// The list of playlist in pm server the song belongs to.
  final List<int>? pmPlaylists;

  /// The song's size in 128k.
  final int size128;

  /// The song's size in 320k.
  final int size320;

  /// The song's size in Ape.
  final int sizeApe;

  /// The song's size in Flac.
  final int sizeFlac;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'singers': singers,
      'cover': cover,
      'payPlay': payPlay,
      'isTakenDown': isTakenDown,
      'songLink': songLink,
      'subTitle': subTitle,
      'albumName': albumName,
      'songId': songId,
      'songMid': songMid,
      'mediaMid': mediaMid,
      'duration': duration,
      'songDesc': songDesc,
      'pubTime': pubTime,
      'lyrics': lyrics.toJson(),
      'pmPlaylists': pmPlaylists,
      'size128': size128,
      'size320': size320,
      'sizeApe': sizeApe,
      'sizeFlac': sizeFlac
    };
  }

  factory QQMusicDetailSong.fromJson(Map<String, dynamic> json) {
    QQMusicLyrics lyrics = QQMusicLyrics.fromJson(json['lyrics']);

    List<dynamic> singersJson = json['singers'];
    List<QQMusicSinger> singers =
        singersJson.map((e) => QQMusicSinger.fromJson(e)).toList();

    return QQMusicDetailSong(
      json['subTitle'],
      json['albumName'],
      json['songId'],
      json['songMid'],
      json['mediaMid'],
      json['duration'],
      json['songDesc'],
      json['pubTime'],
      lyrics,
      json['pmPlaylists'],
      json['size128'],
      json['size320'],
      json['sizeApe'],
      json['sizeFlac'],
      name: json['name'],
      singers: singers,
      cover: json['cover'],
      payPlay: json['payPlay'],
      isTakenDown: json['isTakenDown'],
      songLink: json['songLink'],
    );
  }

  @override
  String toString() {
    return 'QQMusicDetailSong(name: $name, singers: $singers, cover: $cover, payPlay: $payPlay, isTakenDown: $isTakenDown, songLink: $songLink, subTitle: $subTitle, albumName: $albumName, songId: $songId, songMid: $songMid, mediaMid: $mediaMid, duration: $duration, songDesc: $songDesc, pubTime: $pubTime, lyrics: $lyrics, pmPlaylists: $pmPlaylists, size128: $size128, size320: $size320, sizeApe: $sizeApe, sizeFlac: $sizeFlac)';
  }
}
