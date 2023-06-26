import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/third_lib_change/just_audio/common.dart';
import 'package:rxdart/rxdart.dart';

class MyAppState extends ChangeNotifier {
  // Current position in milliseconds.
  int? _playProgress;

  // Set true when init song player for cover animation forward.
  bool _isFirstLoadSongPlayer = false;

  // Current song in queue.
  Song? _currentSong;

  // Is removing song from queue?
  bool _isRemovingSongFromQueue = false;

  // If the song player page is opened.
  bool _isPlayerPageOpened = false;

  // Make sure song player page pop once.
  bool _canSongPlayerPagePop = false;

  // If remove song in queue, this should be true for update the current song.
  bool _updateSong = false;

  // Current song player.
  AudioPlayer? _player;

  // Current queue.
  List<Song>? _queue;

  // Define the queue.
  ConcatenatingAudioSource? _initQueue;

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player?.createPositionStream(
              minPeriod: Duration(milliseconds: 1),
              maxPeriod: Duration(milliseconds: 1),
            ) ??
            Stream.empty(),
        _player?.bufferedPositionStream ?? Stream.empty(),
        _player?.durationStream ?? Stream.empty(),
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  bool _isPlaying = false;

  // Volume of song player.
  double? _volume = 1.0;

  // Speed of song player.
  double? _speed = 1.0;

  // User playing mode, 0 for shuffle, 1 for repeat, 2 for repeat one.
  int _userPlayingMode = 1;

  // Current playing song in queue.
  int? _currentPlayingSongInQueue;

  // All songs of current playlist.
  List<Song>? _songsOfPlaylist;

  // Cover rotating controller.
  AnimationController? _coverRotatingController;

  CarouselController _carouselController = CarouselController();

  // // Init current song player only one time.
  // bool _initSongPlayer = true;
  String _currentPage = '/';

  Playlist? _openedPlaylist;

  int? get playProgress => _playProgress;

  bool get isFirstLoadSongPlayer => _isFirstLoadSongPlayer;

  Song? get currentSong => _currentSong;

  AnimationController? get coverRotatingController => _coverRotatingController;

  bool get isRemovingSongFromQueue => _isRemovingSongFromQueue;

  bool get isPlayerPageOpened => _isPlayerPageOpened;

  bool get canSongPlayerPagePop => _canSongPlayerPagePop;

  bool get updateSong => _updateSong;

  CarouselController get carouselController => _carouselController;

  AudioPlayer? get player => _player;

  String get currentPage => _currentPage;

  bool get isPlaying => _isPlaying;

  ConcatenatingAudioSource? get initQueue => _initQueue;

  // bool get initSongPlayer => _initSongPlayer;

  int get userPlayingMode => _userPlayingMode;

  Playlist? get openedPlaylist => _openedPlaylist;

  bool get isQueueEmpty => _queue?.isEmpty ?? true;

  List<Song>? get queue => _queue;

  // List<Song>? get prevQueue => _prevQueue;

  List<Song>? get songsOfPlaylist => _songsOfPlaylist;

  int? get currentPlayingSongInQueue => _currentPlayingSongInQueue;

  double? get volume => _volume;

  double? get speed => _speed;

  set playProgress(int? value) {
    _playProgress = value;
    notifyListeners();
  }

  set isFirstLoadSongPlayer(bool value) {
    _isFirstLoadSongPlayer = value;
    notifyListeners();
  }

  set currentSong(Song? value) {
    _currentSong = value;
    notifyListeners();
  }

  set coverRotatingController(AnimationController? value) {
    _coverRotatingController = value;
    notifyListeners();
  }

  set isRemovingSongFromQueue(bool value) {
    _isRemovingSongFromQueue = value;
    notifyListeners();
  }

  set isPlayerPageOpened(bool value) {
    _isPlayerPageOpened = value;
    notifyListeners();
  }

  set canSongPlayerPagePop(bool value) {
    _canSongPlayerPagePop = value;
    notifyListeners();
  }

  set updateSong(bool value) {
    _updateSong = value;
    notifyListeners();
  }

  set player(AudioPlayer? player) {
    _player = player;
    notifyListeners();
  }

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

  // set initSongPlayer(init) {
  //   _initSongPlayer = init;
  //   notifyListeners();
  // }

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

  // set prevQueue(prevQueue) {
  //   _prevQueue = List.from(prevQueue);
  //   notifyListeners();
  // }

  set songsOfPlaylist(songs) {
    _songsOfPlaylist = List.from(songs);
    notifyListeners();
  }

  set currentPlayingSongInQueue(index) {
    _currentPlayingSongInQueue = index;
    notifyListeners();
  }

  void removeSongInQueue(int index) {
    if (_queue?.isNotEmpty ?? false) {
      _queue!.removeAt(index);
    }
    notifyListeners();
  }

  Future<void> initAudioPlayer() async {
    _player = AudioPlayer();

    // Try to load audio from a source and catch any errors.
    try {
      initTheQueue();
      await _player!.setAudioSource(_initQueue!,
          initialIndex: _currentPlayingSongInQueue,
          initialPosition: Duration.zero);

      // Set the playing mode of the player.
      if (_userPlayingMode == 0) {
        await _player!.setShuffleModeEnabled(true);
        await _player!.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 1) {
        await _player!.setShuffleModeEnabled(false);
        await _player!.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 2) {
        await _player!.setShuffleModeEnabled(false);
        await _player!.setLoopMode(LoopMode.one);
      } else {
        throw Exception('Invalid playing mode');
      }

      // Set the volume.
      await _player!.setVolume(_volume!);
      // Set the speed.
      await _player!.setSpeed(speed!);

      // Listen to errors during playback.
      _player!.playbackEventStream.listen(
        (event) {
          // bool skip = false;
          // if (_queue!.length != _originQueue!.length && _queue!.isNotEmpty) {
          //   for (int i = 0; i < _originQueue!.length; i++) {
          //     if (!_queue!.contains(_originQueue![i])) {
          //       _initQueue.removeAt(i);
          //       _originQueue!.removeAt(i);
          //       // if (i <= _currentSongIndex) {
          //       //   // TODO: fix bug: when call _initQueue.removeAt(i); the _currentSongIndex
          //       //   // will be subtracted one more time.
          //       //   // _player.seek(Duration.zero, index: _currentSongIndex);
          //       //   skip = true;
          //       //   return;
          //       // }
          //       break;
          //     }
          //   }
          // }
          // if ( //event.currentIndex != null &&
          // event.currentIndex != _currentPlayingSongInQueue // &&
          // event.currentIndex! < _queue!.length &&
          // ) {
          // _currentPlayingSongInQueue = event.currentIndex!;
          // _carouselController.nextPage();
          // notifyListeners();
          // _carouselController.jumpToPage(_currentSongIndex);
          // Future.delayed(Duration(milliseconds: 300), () {
          //   _appState.currentPlayingSongInQueue = _currentSongIndex;
          // });

          //   if (_userPlayingMode == 0) {
          //     _player.shuffle();
          //     // _player.seek(Duration.zero, index: _player.effectiveIndices?[0]);
          //   }

          //   setState(() {});
          // }
        },
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        },
      );
      // _player!.currentIndexStream.listen((event) {});
      // TODO: fix bug: when remove song in playlist, this function will also be called.
      _player!.positionDiscontinuityStream.listen((discontinuity) {
        // _coverRotatingController!.value = 0;
        if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance &&
            !_updateSong &&
            !_isRemovingSongFromQueue) {
          if (_userPlayingMode == 0) {
            _currentPlayingSongInQueue = _player!.nextIndex;
            notifyListeners();
            _carouselController.animateToPage(_player!.effectiveIndices!
                .indexOf(_currentPlayingSongInQueue!));
          } else if (_userPlayingMode == 1) {
            _currentPlayingSongInQueue =
                _player!.nextIndex ?? _currentPlayingSongInQueue;
            notifyListeners();
            _carouselController.animateToPage(_currentPlayingSongInQueue!);
          } else {
            return;
          }
          // _currentPlayingSongInQueue = discontinuity.event.currentIndex;
          // notifyListeners();
          // _carouselController.animateToPage(
          //     _player!.effectiveIndices!.indexOf(_player.nextIndex));
        }
      });
// audioPlayer?.onDurationChanged.listen((Duration event) {
//                     setState(() {
//                       max_value = event.inMilliseconds.toDouble();
//                     });
//                   });
      //             audioPlayer?.onPositionChanged.listen((Duration event) {
      //               if (isTap) return;
      //               setState(() {
      //                 sliderProgress = event.inMilliseconds.toDouble();
      //                 playProgress = event.inMilliseconds;
      //               });
      //             });
      // _player!.positionStream.listen((event) {
      //   // _sliderProgress = event.inMilliseconds.toDouble();
      //   _playProgress = event.inMilliseconds;
      //   notifyListeners();
      // });
      // _player!.positionStream.listen((event) {
      //   // _sliderProgress = event.inMilliseconds.toDouble();
      //     // _sliderProgress = event.inMilliseconds.toDouble();
      //     playProgress = event.inMilliseconds;
      // });
      // _player!.durationStream.listen((event) {
      //     max_value = event!.inMilliseconds.toDouble();
      // });
      _player!.playingStream.listen((playing) {
        isPlaying = playing;
      });
      // await _player!.play();
      // if (_isPlaying) {
      //   await _player!.play();
      // }
    } catch (e) {
      print("Error init audio player: $e");
    }

    // void toggleBottomPlayer() {
    //   _isQueueEmpty = !_isQueueEmpty;
    //   notifyListeners();
    // }
  }

  void initTheQueue() {
    _initQueue = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the queue items
      children: _queue!
          .map(
            (e) => AudioSource.asset(e.link),
          )
          .toList(),
    );
  }
}
