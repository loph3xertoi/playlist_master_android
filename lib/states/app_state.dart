import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/entities/song.dart';

class MyAppState extends ChangeNotifier {
  String _currentPage = '/';

  bool _isPlaying = false;

  // Volume of song player.
  double? _volume = 1.0;

  // Speed of song player.
  double? _speed = 1.0;

  // Init current song player only one time.
  bool _initSongPlayer = true;

  int _userPlayingMode = 0;

  int _currentPlayingSongInQueue = 0;

  Playlist? _openedPlaylist;

  List<Song>? _songsOfPlaylist;

  List<Song>? _queue;

  String get currentPage => _currentPage;

  bool get isPlaying => _isPlaying;

  bool get initSongPlayer => _initSongPlayer;

  int get userPlayingMode => _userPlayingMode;

  Playlist? get openedPlaylist => _openedPlaylist;

  bool get isQueueEmpty => _queue?.isEmpty ?? true;

  List<Song>? get queue => _queue;

  List<Song>? get songsOfPlaylist => _songsOfPlaylist;

  int get currentPlayingSongInQueue => _currentPlayingSongInQueue;

  double? get volume => _volume;

  double? get speed => _speed;

  set currentPage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  set isPlaying(isPlaying) {
    _isPlaying = isPlaying;
    notifyListeners();
  }

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

  set openedPlaylist(Playlist? playlist) {
    _openedPlaylist = playlist;
    notifyListeners();
  }

  set queue(queue) {
    _queue = List.from(queue);
    notifyListeners();
  }

  set songsOfPlaylist(songs) {
    _songsOfPlaylist = List.from(songs);
    notifyListeners();
  }

  set currentPlayingSongInQueue(index) {
    _currentPlayingSongInQueue = index;
    notifyListeners();
  }

  // void toggleBottomPlayer() {
  //   _isQueueEmpty = !_isQueueEmpty;
  //   notifyListeners();
  // }
}
