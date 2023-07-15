import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_detail_video.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/basic/basic_video.dart';
import '../entities/qq_music/qqmusic_detail_playlist.dart';
import '../entities/qq_music/qqmusic_detail_song.dart';
import '../entities/qq_music/qqmusic_playlist.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../entities/qq_music/qqmusic_video.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../third_lib_change/just_audio/common.dart';
import '../utils/get_video_type.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';

class MyAppState extends ChangeNotifier {
  // Last video's vid.
  String _lastVideoVid = '';

  // The time when quit video.
  int _videoSeekTime = 0;

  // Dark mode.
  bool? _isDarkMode;

  // Using mock data.
  bool _isUsingMockData = false;

  /// The current platform, 0 for pm server, 1 for qq music, 2 for netease music, 3 for bilibili.
  int _currentPlatform = 1;

  // Default image for cover.
  static const String defaultCoverImage =
      'https://img0.baidu.com/it/u=819122015,412168181&fm=253&fmt=auto&app=138&f=JPEG?w=320&h=320';
  // static const String defaultCoverImage =
  //     'https://www.worldwildlife.org/assets/structure/unique/logo-c562409bb6158bf64e5f8b1be066dbd5983d75f5ce7c9935a5afffbcc03f8e5d.png';

  static const String defaultLibraryCover =
      'http://y.gtimg.cn/mediastyle/global/img/cover_playlist.png?max_age=31536000';

  // Set true when init song player for cover animation forward.
  bool _isFirstLoadSongPlayer = false;

  // Current basic playing song.
  BasicSong? _currentSong;

  // Previous basic playing song.
  BasicSong? _prevSong;

  // Current detail playing song.
  BasicSong? _currentDetailSong;

  // Is removing song from queue?
  bool _isRemovingSongFromQueue = false;

  // Whether the song player page is opened.
  bool _isPlayerPageOpened = false;

  // Make sure song player page pop once.
  bool _canSongPlayerPagePop = false;

  // Whether remove song in queue, this should be true for update the current song.
  bool _updateSong = false;

  // Current song player.
  AudioPlayer? _player;

  // Current queue.
  List<BasicSong>? _queue;

  // Raw queue of the library.
  List<BasicSong>? _rawQueue;

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
  int _currentPlayingSongInQueue = 0;

  // All songs of current playlist.
  // List<Song>? _songsOfPlaylist;

  // Cover rotating controller.
  AnimationController? _coverRotatingController;

  CarouselController _carouselController = CarouselController();

  // Previous carousel index.
  int _prevCarouselIndex = 0;

  // // Init current song player only one time.
  // bool _initSongPlayer = true;
  // String _currentPage = '/';

  // Current opened library, will change when navigate to similar song page.
  BasicLibrary? _openedLibrary;

  // Raw opened library.
  BasicLibrary? _rawOpenedLibrary;

  String get lastVideoVid => _lastVideoVid;

  int get videoSeekTime => _videoSeekTime;

  /// The current platform, 0 for pm server, 1 for qq music, 2 for netease music, 3 for bilibili.
  int get currentPlatform => _currentPlatform;

  bool? get isDarkMode => _isDarkMode;

  int get prevCarouselIndex => _prevCarouselIndex;

  BasicSong? get prevSong => _prevSong;

  BasicSong? get currentDetailSong => _currentDetailSong;

  bool get isUsingMockData => _isUsingMockData;

  // int? get playProgress => _playProgress;

  bool get isFirstLoadSongPlayer => _isFirstLoadSongPlayer;

  BasicSong? get currentSong => _currentSong;

  AnimationController? get coverRotatingController => _coverRotatingController;

  bool get isRemovingSongFromQueue => _isRemovingSongFromQueue;

  bool get isPlayerPageOpened => _isPlayerPageOpened;

  bool get canSongPlayerPagePop => _canSongPlayerPagePop;

  bool get updateSong => _updateSong;

  CarouselController get carouselController => _carouselController;

  AudioPlayer? get player => _player;

  // String get currentPage => _currentPage;

  bool get isPlaying => _isPlaying;

  ConcatenatingAudioSource? get initQueue => _initQueue;

  // bool get initSongPlayer => _initSongPlayer;

  int get userPlayingMode => _userPlayingMode;

  BasicLibrary? get openedLibrary => _openedLibrary;

  BasicLibrary? get rawOpenedLibrary => _rawOpenedLibrary;

  bool get isQueueEmpty => _queue?.isEmpty ?? true;

  List<BasicSong>? get queue => _queue;

  List<BasicSong>? get rawQueue => _rawQueue;

  // List<BasicSong>? get prevQueue => _prevQueue;

  // List<BasicSong>? get songsOfPlaylist => _songsOfPlaylist;

  int? get currentPlayingSongInQueue => _currentPlayingSongInQueue;

  double? get volume => _volume;

  double? get speed => _speed;

  set lastVideoVid(String value) {
    _lastVideoVid = value;
  }

  set videoSeekTime(int value) {
    _videoSeekTime = value;
  }

  /// The current platform, 0 for pm server, 1 for qq music, 2 for netease music, 3 for bilibili.
  set currentPlatform(int value) {
    _currentPlatform = value;
    notifyListeners();
  }

  set isDarkMode(bool? value) {
    _isDarkMode = value;
    notifyListeners();
  }

  set rawQueue(value) {
    _rawQueue = List.from(value);
    notifyListeners();
  }

  set prevCarouselIndex(int value) {
    _prevCarouselIndex = value;
    notifyListeners();
  }

  set prevSong(BasicSong? value) {
    _prevSong = value;
    notifyListeners();
  }

  set currentDetailSong(BasicSong? value) {
    _currentDetailSong = value;
    notifyListeners();
  }

  set isUsingMockData(bool value) {
    _isUsingMockData = value;
    notifyListeners();
  }

  // set playProgress(int? value) {
  //   _playProgress = value;
  //   notifyListeners();
  // }

  set isFirstLoadSongPlayer(bool value) {
    _isFirstLoadSongPlayer = value;
    notifyListeners();
  }

  set currentSong(BasicSong? value) {
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

  // set currentPage(String page) {
  //   _currentPage = page;
  //   notifyListeners();
  // }

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

  set openedLibrary(BasicLibrary? library) {
    _openedLibrary = library;
    notifyListeners();
  }

  set rawOpenedLibrary(BasicLibrary? library) {
    _rawOpenedLibrary = library;
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

  // set songsOfPlaylist(songs) {
  //   _songsOfPlaylist = List.from(songs);
  //   notifyListeners();
  // }

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
      _initQueue = await initTheQueue();

      // Listen to errors during playback.
      _player!.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        },
      );

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

      // _player!.currentIndexStream.listen((event) {});
      // TODO: fix bug: when remove song in library, this function will also be called.
      _player!.positionDiscontinuityStream.listen((discontinuity) {
        // _coverRotatingController!.value = 0;
        if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance &&
            !_updateSong &&
            !_isRemovingSongFromQueue) {
          if (_userPlayingMode == 0) {
            currentPlayingSongInQueue = discontinuity.event.currentIndex;
            currentSong = _queue![currentPlayingSongInQueue!];
            prevCarouselIndex = currentPlayingSongInQueue!;
            // _carouselController.animateToPage(_player!.effectiveIndices!
            // .indexOf(_currentPlayingSongInQueue!));
          } else if (_userPlayingMode == 1) {
            currentPlayingSongInQueue =
                discontinuity.event.currentIndex ?? _currentPlayingSongInQueue;
            currentSong = _queue![currentPlayingSongInQueue!];
            prevCarouselIndex = currentPlayingSongInQueue!;
            // _carouselController.animateToPage(_currentPlayingSongInQueue!);
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
      print('Error init audio player: $e');
      throw Exception('Error init audio player: $e');
    }
  }

  Future<BasicSong?> fetchDetailSong(BasicSong song, int platform) async {
    Uri? url;
    if (platform == 1) {
      url = Uri.http(
          API.host, '${API.detailSong}/${(song as QQMusicSong).songMid}', {
        'platform': platform.toString(),
      });
    }
    MyLogger.logger.d('Loading detail song from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url!);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        if (platform == 1) {
          return Future.value(
              QQMusicDetailSong.fromJson(decodedResponse['data']));
        } else {
          throw Exception('Only imeplement qq music platform');
        }
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<Map<String, List<String>>?> fetchMVsLink(
      List<String> vids, int platform) async {
    Uri url = Uri.http(API.host, '${API.mvLink}/${vids.join(',')}', {
      'platform': platform.toString(),
    });
    MyLogger.logger.d('Loading MVs link from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        var mvsLink = decodedResponse['data']!;
        if (mvsLink is Map<String, dynamic>) {
          return Future.value(mvsLink.map((key, value) =>
              MapEntry<String, List<String>>(key, List<String>.from(value))));
        } else {
          throw Exception('Only imeplement qq music platform');
        }
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<Map<String, String>?> fetchSongsLink(
      List<String> songMids, int platform) async {
    Uri url = Uri.http(API.host, '${API.songsLink}/${songMids.join(',')}', {
      'platform': platform.toString(),
    });
    MyLogger.logger.d('Loading songs link from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        var songsLink = decodedResponse['data']!;
        return Future.value(
            songsLink.map((key, value) => MapEntry(key, value.toString())));
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<BasicLibrary?> fetchDetailLibrary(
      BasicLibrary library, int platform) async {
    Uri? url;
    if (platform == 1) {
      url = Uri.http(API.host,
          '${API.detailLibrary}/${(library as QQMusicPlaylist).tid}', {
        'platform': platform.toString(),
      });
    }
    MyLogger.logger.d('Loading detail library from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url!);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        if (platform == 1) {
          return Future.value(
              QQMusicDetailPlaylist.fromJson(decodedResponse['data']));
        } else {
          throw Exception('Only imeplement qq music platform');
        }
      } else if (response.statusCode == 200 &&
          decodedResponse['success'] == false &&
          platform == 1) {
        MyToast.showToast('Request failure, tid is 0');
        MyLogger.logger.e('Request failure, tid is 0');
        return null;
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<List<BasicSong>?> fetchSimilarSongs(
      BasicSong song, int platform) async {
    Uri? url;
    if (platform == 1) {
      url = Uri.http(
          API.host, '${API.similarSongs}/${(song as QQMusicSong).songId}', {
        'platform': platform.toString(),
      });
    }
    MyLogger.logger.d('Loading similar songs from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url!);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        List<dynamic> jsonList = decodedResponse['data'];
        List<BasicSong>? songs;
        if (platform == 1) {
          songs =
              jsonList.map<BasicSong>((e) => QQMusicSong.fromJson(e)).toList();
        }
        return Future.value(songs);
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<BasicVideo?> fetchDetailMV(BasicVideo video, int platform) async {
    String? vid;
    if (platform == 1) {
      vid = (video as QQMusicVideo).vid;
    } else {
      throw Exception('Only imeplement qq music platform');
    }
    Uri url = Uri.http(API.host, '${API.detailMV}/$vid', {
      'platform': platform.toString(),
    });

    MyLogger.logger.d('Loading detail mv information from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        if (platform == 1) {
          return Future.value(
              QQMusicDetailVideo.fromJson(decodedResponse['data']));
        } else {
          throw Exception('Only imeplement qq music platform');
        }
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  // Cache video.
  Future<void> cacheVideo(String rawUrl) async {
    final client = RetryClient(http.Client());
    String? videoType = VideoUtil.getVideoType(rawUrl);
    if (videoType == null) {
      MyToast.showToast('Video url is corrupted');
      throw Exception('Video url is corrupted');
    }
    CacheManager cacheManager = MyHttp.videoCacheManager;
    dynamic result = await cacheManager.getFileFromCache(rawUrl);
    if (result == null || !(result as FileInfo).file.existsSync()) {
      try {
        var response = await client.get(Uri.parse(rawUrl));
        if (response.statusCode == 200) {
          await cacheManager.putFile(
            rawUrl,
            response.bodyBytes,
            fileExtension: videoType,
          );
          MyToast.showToast('Cache video successfully');
          MyLogger.logger.i('Cache video successfully');
        } else {
          MyToast.showToast('Response error with code: ${response.statusCode}');
          MyLogger.logger.e('Response error with code: ${response.statusCode}');
        }
      } catch (e) {
        MyToast.showToast('Exception thrown: $e');
        MyLogger.logger.e('Network error with exception: $e');
        rethrow;
      } finally {
        client.close();
      }
    } else {
      MyToast.showToast('Already cached');
      MyLogger.logger.wtf('Already cached');
    }
  }

  Future<List<BasicVideo>?> fetchRelatedMVs(
      BasicSong song, int platform) async {
    String? songId;
    if (platform == 1) {
      songId = (song as QQMusicSong).songId;
    } else {
      throw Exception('Only imeplement qq music platform');
    }
    Uri url = Uri.http(API.host, '${API.relatedMV}/$songId', {
      'platform': platform.toString(),
    });

    MyLogger.logger.d('Loading related MVs from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        if (platform == 1) {
          List<dynamic> jsonList = decodedResponse['data'];
          return Future.value(jsonList
              .map<QQMusicVideo>((video) => QQMusicVideo.fromJson(video))
              .toList());
        } else {
          throw Exception('Only imeplement qq music platform');
        }
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<String?> fetchSongLink(
      BasicSong song, String quality, int platform) async {
    Uri? url;
    if (platform == 1) {
      url = Uri.http(
          API.host, '${API.songLink}/${(song as QQMusicSong).songMid}', {
        'mediaMid': song.mediaMid,
        'type': quality,
        'platform': platform.toString(),
      });
    }
    MyLogger.logger.d('Loading song link from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url!);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        String songLink = decodedResponse['data'];
        return Future.value(songLink);
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<ConcatenatingAudioSource?> initTheQueue() async {
    List<AudioSource> queueList;
    List<Future<AudioSource>> songs = [];
    if (isUsingMockData) {
      songs = _queue!
          .map((e) async => AudioSource.asset(
                e.songLink,
                tag: MediaItem(
                  // Specify a unique ID for each media item:
                  id: Uuid().v1(),
                  // Metadata to display in the notification:
                  album: 'Album name',
                  artist: e.singers.map((e) => e.name).join(', '),
                  title: e.name,
                  artUri:
                      await getImageFileFromAssets(e.cover, _queue!.indexOf(e)),
                ),
              ))
          .toList();
    } else {
      songs = _queue!
          .map((e) async => LockCachingAudioSource(
                Uri.parse(e.songLink),
                tag: MediaItem(
                  // Specify a unique ID for each media item:
                  id: Uuid().v1(),
                  // Metadata to display in the notification:
                  album: 'Album name',
                  artist: e.singers.map((e) => e.name).join(', '),
                  title: e.name,
                  artUri: Uri.parse(e.cover),
                ),
              ))
          .toList();
    }

    queueList = await Future.wait(songs);

    return ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the queue items
      children: queueList,
    );
  }

  Future<Uri> getImageFileFromAssets(String imageAssets, int index) async {
    final byteData = await rootBundle.load(imageAssets);
    final buffer = byteData.buffer;
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var filePath =
        '$tempPath/image_tmp_$index.png'; // image_tmp.png is dump file, can be anything
    return (await File(filePath).writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes)))
        .uri;
  }
}
