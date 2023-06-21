import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/entities/song.dart';

class MyAppState extends ChangeNotifier {
  // Volume of song player.
  double? _volume = 1.0;

  // Speed of song player.
  double? _speed = 1.0;

  // Init current song player only one time.
  bool _initSongPlayer = true;

  int _userPlayingMode = 0;

  bool _isQueueEmpty = true;

  int _currentPlayingSongInQueue = 0;

  Playlist? _openedPlaylist;

  List<Song>? _songsOfPlaylist;

  List<Song>? _queue;

  bool get initSongPlayer => _initSongPlayer;

  int get userPlayingMode => _userPlayingMode;

  Playlist? get openedPlaylist => _openedPlaylist;

  bool get isQueueEmpty => _isQueueEmpty;

  List<Song>? get queue => _queue;

  List<Song>? get songsOfPlaylist => _songsOfPlaylist;

  int get currentPlayingSongInQueue => _currentPlayingSongInQueue;

  double? get volume => _volume;

  double? get speed => _speed;

  set speed(speed) {
    _speed = speed;
    notifyListeners();
  }

  set volume(volume) {
    _volume = volume;
    notifyListeners();
  }

  set initSongPlayer(init) {
    _initSongPlayer = init;
    notifyListeners();
  }

  set userPlayingMode(mode) {
    _userPlayingMode = mode;
    notifyListeners();
  }

  set openedPlaylist(playlist) {
    _openedPlaylist = playlist;
    notifyListeners();
  }

  set setQueue(queue) {
    _queue = queue;
    _isQueueEmpty = _queue?.isEmpty ?? true;
    notifyListeners();
  }

  set setSongsOfPlaylist(songs) {
    _songsOfPlaylist = songs;
    notifyListeners();
  }

  set currentPlayingSongInQueue(index) {
    _currentPlayingSongInQueue = index;
    notifyListeners();
  }

  void toggleBottomPlayer() {
    _isQueueEmpty = !_isQueueEmpty;
    notifyListeners();
  }
}
