import 'package:flutter/foundation.dart';

import '../basic/basic_song.dart';
import 'ncm_lyrics.dart';
import 'ncm_singer.dart';

/// Detail song of ncm.
@immutable
class NCMDetailSong extends BasicSong {
  const NCMDetailSong(
      this.id,
      this.mvId,
      this.albumName,
      this.duration,
      this.publishTime,
      this.lyrics,
      this.pmPlaylists,
      this.hBr,
      this.hSize,
      this.mBr,
      this.mSize,
      this.lBr,
      this.lSize,
      this.sqBr,
      this.sqSize,
      {required super.name,
      required super.singers,
      required super.cover,
      required super.payPlay,
      required super.isTakenDown,
      required super.songLink});

  /// The id of this song.
  final int id;

  /// The mv id of this song.
  final int mvId;

  /// The album name of this song.
  final String albumName;

  /// The duration of this song.
  final int duration;

  /// The release time of this song
  final String publishTime;

  /// PMSSong's lyrics.
  final NCMLyrics lyrics;

  /// The list of playlist in pm server the song beints to.
  final List<int> pmPlaylists;

  /// High bitrate of this song.
  final int hBr;

  /// The size of high bitrate of this song.
  final int hSize;

  /// Middle bitrate of this song.
  final int mBr;

  /// The size of middle bitrate of this song.
  final int mSize;

  /// Low bitrate of this song.
  final int lBr;

  /// The size of low bitrate of this song.
  final int lSize;

  /// Super quality bitrate of this song.
  final int sqBr;

  /// The size of Super quality bitrate of this song.
  final int sqSize;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'singers': singers,
      'cover': cover,
      'payPlay': payPlay,
      'isTakenDown': isTakenDown,
      'songLink': songLink,
      'id': id,
      'mvId': mvId,
      'albumName': albumName,
      'duration': duration,
      'publishTime': publishTime,
      'lyrics': lyrics,
      'pmPlaylists': pmPlaylists,
      'hBr': hBr,
      'hSize': hSize,
      'mBr': mBr,
      'mSize': mSize,
      'lBr': lBr,
      'lSize': lSize,
      'sqBr': sqBr,
      'sqSize': sqSize
    };
  }

  factory NCMDetailSong.fromJson(Map<String, dynamic> json) {
    NCMLyrics lyrics = NCMLyrics.fromJson(json['lyrics']);

    List<dynamic> singersJson = json['singers'];
    List<NCMSinger> singers =
        singersJson.map((e) => NCMSinger.fromJson(e)).toList();

    return NCMDetailSong(
      json['id'],
      json['mvId'],
      json['albumName'],
      json['duration'],
      json['publishTime'],
      lyrics,
      json['pmPlaylists'],
      json['hBr'],
      json['hSize'],
      json['mBr'],
      json['mSize'],
      json['lBr'],
      json['lSize'],
      json['sqBr'],
      json['sqSize'],
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
    return 'NCMDetailSong(name: $name, singers: $singers, cover: $cover, payPlay: $payPlay, isTakenDown: $isTakenDown, songLink: $songLink, id: $id, mvId: $mvId, albumName: $albumName, duration: $duration, publishTime: $publishTime, lyrics: $lyrics, pmPlaylists: $pmPlaylists, hBr: $hBr, hSize: $hSize, mBr: $mBr, mSize: $mSize, lBr: $lBr, lSize: $lSize, sqBr: $sqBr, sqSize: $sqSize)';
  }
}
