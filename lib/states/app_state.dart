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
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_paged_songs.dart';
import '../entities/basic/basic_song.dart';
import '../entities/basic/basic_user.dart';
import '../entities/basic/basic_video.dart';
import '../entities/dto/result.dart';
import '../entities/netease_cloud_music/ncm_playlist.dart';
import '../entities/netease_cloud_music/ncm_user.dart';
import '../entities/qq_music/qqmusic_detail_playlist.dart';
import '../entities/qq_music/qqmusic_detail_song.dart';
import '../entities/qq_music/qqmusic_detail_video.dart';
import '../entities/qq_music/qqmusic_paged_songs.dart';
import '../entities/qq_music/qqmusic_playlist.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../entities/qq_music/qqmusic_user.dart';
import '../entities/qq_music/qqmusic_video.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../third_lib_change/just_audio/common.dart';
import '../utils/get_video_type.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';

class MyAppState extends ChangeNotifier {
  // Refresh detail library page.
  void Function(MyAppState)? refreshDetailLibraryPage;

  // Remove library from libraries in home page.
  void Function(BasicLibrary)? removeLibraryFromLibraries;

  // Refresh home page's libraries.
  Future<List<BasicLibrary>?> Function(MyAppState, bool)? refreshLibraries;

  // Current page.
  int _currentPage = 2;

  // First page number.
  int _firstPageNo = 1;

  // Searching page size.
  int _pageSize = 20;

  // Total searched songs count.
  int _totalSearchedSongs = 0;

  // Searched songs.
  List<BasicSong> _searchedSongs = [];

  // Searching keyword.
  String? _searchingString;

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

  int get currentPage => _currentPage;

  int get firstPageNo => _firstPageNo;

  int get pageSize => _pageSize;

  int get totalSearchedSongs => _totalSearchedSongs;

  List<BasicSong> get searchedSongs => _searchedSongs;

  String? get searchingString => _searchingString;

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

  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  set totalSearchedSongs(int value) {
    _totalSearchedSongs = value;
    notifyListeners();
  }

  set searchedSongs(List<BasicSong> value) {
    _searchedSongs = List.from(value);
    notifyListeners();
  }

  set searchingString(String? value) {
    _searchingString = value;
    notifyListeners();
  }

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
        throw UnsupportedError('Invalid playing mode');
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
        }
      });
      _player!.playingStream.listen((playing) {
        isPlaying = playing;
      });
    } catch (e) {
      print('Error init audio player: $e');
      throw Exception('Error init audio player: $e');
    }
  }

  Future<BasicUser?> fetchUser(int platform) async {
    BasicUser Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicUser.fromJson;
    } else if (platform == 2) {
      resolveJson = NCMUser.fromJson;
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      '${API.user}/${API.uid}',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading User information from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        Map<String, dynamic> user = decodedResponse['data'];
        return Future.value(resolveJson(user));
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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

  Future<BasicSong?> fetchDetailSong(BasicSong song, int platform) async {
    BasicSong Function(Map<String, dynamic>) resolveJson;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicDetailSong.fromJson;
      url = Uri.http(
        API.host,
        '${API.detailSong}/${(song as QQMusicSong).songMid}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading detail song from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        return Future.value(resolveJson(decodedResponse['data']));
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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
    // BasicLibrary Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      // resolveJson = QQMusicPlaylist.fromJson;
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      '${API.mvLink}/${vids.join(',')}',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading MVs link from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        var mvsLink = decodedResponse['data']!;
        // if (mvsLink is Map<String, dynamic>) {
        return Future.value(mvsLink.map((key, value) =>
            MapEntry<String, List<String>>(key, List<String>.from(value))));
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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
      List<String> songIds, int platform) async {
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      '${API.songsLink}/${songIds.join(',')}',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading songs link from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        var songsLink = decodedResponse['data']!;
        return Future.value(
            songsLink.map((key, value) => MapEntry(key, value.toString())));
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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
    BasicLibrary Function(Map<String, dynamic>) resolveJson;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicDetailPlaylist.fromJson;
      url = Uri.http(
        API.host,
        '${API.detailLibrary}/${(library as QQMusicPlaylist).tid}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading detail library from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        return Future.value(resolveJson(decodedResponse['data']));
      } else if (response.statusCode == 200 &&
          decodedResponse['success'] == false &&
          platform == 1) {
        MyToast.showToast('Request failure, tid is 0');
        MyLogger.logger.e('Request failure, tid is 0');
        return null;
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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
    BasicSong Function(Map<String, dynamic>) resolveJson;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicSong.fromJson;
      url = Uri.http(
        API.host,
        '${API.similarSongs}/${(song as QQMusicSong).songId}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading similar songs from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        List<dynamic> jsonList = decodedResponse['data'];
        return Future.value(
            jsonList.map<BasicSong>((e) => resolveJson(e)).toList());
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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
    BasicVideo Function(Map<String, dynamic>) resolveJson;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicDetailVideo.fromJson;
      url = Uri.http(
        API.host,
        '${API.detailMV}/${(video as QQMusicVideo).vid}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading detail mv information from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        return Future.value(resolveJson(decodedResponse['data']));
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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
        final response = await client.get(Uri.parse(rawUrl));
        if (response.statusCode == 200) {
          await cacheManager.putFile(
            rawUrl,
            response.bodyBytes,
            fileExtension: videoType,
          );
          MyToast.showToast('Cache video successfully');
          MyLogger.logger.i('Cache video successfully');
        } else {
          MyToast.showToast('Response error: $response');
          MyLogger.logger.e('Response error: $response');
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
    BasicVideo Function(Map<String, dynamic>) resolveJson;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicVideo.fromJson;
      url = Uri.http(
        API.host,
        '${API.relatedMV}/${(song as QQMusicSong).songId}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading related MVs from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        List<dynamic> jsonList = decodedResponse['data'];
        return Future.value(
            jsonList.map<BasicVideo>((video) => resolveJson(video)).toList());
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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

  Future<Result> createLibrary(String libraryName, int platform) async {
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
    } else if (platform == 2) {
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      API.createLibrary,
      {
        'platform': platform.toString(),
      },
    );
    final requestBody = {'name': libraryName};
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Creating library...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        MyToast.showToast('Library created successfully');
        return Result(true, data: decodedResponse['data']);
      } else {
        MyToast.showToast(decodedResponse['errorMsg']);
        MyLogger.logger.e(decodedResponse['errorMsg']);
        return Result(false, errorMsg: decodedResponse['errorMsg']);
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<Map<String, Object>?> deleteLibraries(
      List<BasicLibrary> libraries, int platform) async {
    String librariesIds;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      if (libraries[0] is QQMusicPlaylist) {
        librariesIds = libraries
            .map((library) => (library as QQMusicPlaylist).dirId)
            .join(",");
      } else {
        librariesIds = libraries
            .map((library) => (library as QQMusicDetailPlaylist).dirId)
            .join(",");
      }
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      '${API.deleteLibrary}/$librariesIds',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Deleting libraries...');
      final response = await client.delete(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        Map<String, Object> result = {};
        Map<String, dynamic> resultJson = decodedResponse['data'];
        int resultCode = resultJson['result'];
        result.putIfAbsent('result', () => resultCode);
        if (resultCode == 100) {
          MyToast.showToast('Delete libraries successfully');
        } else {
          MyToast.showToast('Delete libraries failed: $resultJson');
        }
        return Future.value(result);
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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

  Future<BasicPagedSongs?> fetchSearchedSongs(
      String keywords, int offset, int limit, int platform) async {
    BasicPagedSongs Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicPagedSongs.fromJson;
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(API.host, '${API.searchSong}/$keywords', {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'platform': platform.toString(),
    });
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Searching songs from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        return Future.value(resolveJson(decodedResponse['data']));
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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

  Future<List<BasicLibrary>?> fetchLibraries(int platform) async {
    BasicLibrary Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicPlaylist.fromJson;
    } else if (platform == 2) {
      resolveJson = NCMPlaylist.fromJson;
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      API.libraries,
      {
        'id': API.uid,
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading libraries from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        var jsonList = decodedResponse['data'];
        return Future.value(
            jsonList.map<BasicLibrary>((e) => resolveJson(e)).toList());
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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

  // Future<String?> fetchSongLink(
  //     BasicSong song, String quality, int platform) async {
  //   Uri? url;
  //   if (platform == 1) {
  //     url = Uri.http(
  //         API.host, '${API.songLink}/${(song as QQMusicSong).songMid}', {
  //       'mediaMid': song.mediaMid,
  //       'type': quality,
  //       'platform': platform.toString(),
  //     });
  //   }
  //   final client = RetryClient(http.Client());
  //   try {
  //     MyLogger.logger.i('Loading song link from network...');
  //     final response = await client.get(url!);
  //     final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
  //     if (response.statusCode == 200 && decodedResponse['success'] == true) {
  //       String songLink = decodedResponse['data'];
  //       return Future.value(songLink);
  //     } else {
  //       MyToast.showToast('Response error with code: ${response.statusCode}');
  //       MyLogger.logger.e('Response error with code: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     MyToast.showToast('Exception thrown: $e');
  //     MyLogger.logger.e('Network error with exception: $e');
  //     rethrow;
  //   } finally {
  //     client.close();
  //   }
  // }

  Future<Map<String, Object>?> addSongsToLibrary(
      List<BasicSong> songs, BasicLibrary library, int platform) async {
    Map<String, Object> requestBody;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      int dirId = (library as QQMusicPlaylist).dirId;
      String songsMid = songs.map((e) => (e as QQMusicSong).songMid).join(',');
      String tid = library.tid;
      requestBody = {
        'libraryId': dirId.toString(),
        'songsId': songsMid,
        'tid': tid,
      };
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      API.addSongsToLibrary,
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Adding songs to library...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        Map<String, Object> result = {};
        Map<String, dynamic> resultJson = decodedResponse['data'];
        int resultCode = resultJson['result'];
        result.putIfAbsent('result', () => resultCode);
        if (resultCode == 100) {
          MyToast.showToast('Songs added');
        } else if (resultCode == 200) {
          result.putIfAbsent('errMsg', () => 'Name already exists');
        } else {
          throw Exception('Add songs to library failed: $decodedResponse');
        }
        return Future.value(result);
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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

  Future<Map<String, Object>?> removeSongsFromLibrary(
      List<BasicSong> songs, BasicLibrary library, int platform) async {
    BasicLibrary Function(Map<String, dynamic>) resolveJson;
    Map<String, Object> requestBody;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicPlaylist.fromJson;
      int dirId = (library as QQMusicPlaylist).dirId;
      String tid = library.tid;
      String songsId = songs.map((e) => (e as QQMusicSong).songId).join(',');
      url = Uri.http(
        API.host,
        API.removeSongsFromLibrary,
        {
          'libraryId': dirId.toString(),
          'songsId': songsId,
          'platform': platform.toString(),
          'tid': tid,
        },
      );
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Removing songs from library...');
      final response = await client.delete(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        Map<String, Object> result = {};
        Map<String, dynamic> resultJson = decodedResponse['data'];
        int resultCode = resultJson['result'];
        result.putIfAbsent('result', () => resultCode);
        if (resultCode == 100) {
          MyToast.showToast('Songs removed from ${library.name}');
        } else if (resultCode == 200) {
          MyToast.showToast('Removing songs error: $decodedResponse');
          result.putIfAbsent('errMsg', () => resultJson['errMsg']);
        } else {
          throw Exception('Remove songs from library failed: $resultJson');
        }
        return Future.value(result);
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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

  Future<Map<String, Object>?> moveSongsToOtherLibrary(
    List<BasicSong> songs,
    BasicLibrary srcLibrary,
    BasicLibrary dstLibrary,
    int platform,
  ) async {
    BasicLibrary Function(Map<String, dynamic>) resolveJson;
    Map<String, Object> requestBody;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicPlaylist.fromJson;
      String songsId = songs.map((e) => (e as QQMusicSong).songId).join(',');
      int srcDirId = (srcLibrary as QQMusicPlaylist).dirId;
      int dstDirId = (dstLibrary as QQMusicPlaylist).dirId;
      String srcTid = srcLibrary.tid;
      String dstTid = dstLibrary.tid;
      url = Uri.http(
        API.host,
        API.moveSongsToOtherLibrary,
        {
          'platform': platform.toString(),
        },
      );
      requestBody = {
        'songsId': songsId,
        'fromLibrary': srcDirId.toString(),
        'toLibrary': dstDirId.toString(),
        'fromTid': srcTid,
        'toTid': dstTid,
      };
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Moving songs to other library...');
      final response = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        Map<String, Object> result = {};
        Map<String, dynamic> resultJson = decodedResponse['data'];
        int resultCode = resultJson['result'];
        result.putIfAbsent('result', () => resultCode);
        if (resultCode == 100) {
          MyToast.showToast('Songs moved successfully');
        } else if (resultCode == 200) {
          result.putIfAbsent('errMsg', () => resultJson['errMsg']);
          MyToast.showToast('Songs moved error: $decodedResponse');
        } else {
          throw Exception('Moving songs failed: $resultJson');
        }
        return Future.value(result);
      } else {
        MyToast.showToast('Response error: $decodedResponse');
        MyLogger.logger.e('Response error: $decodedResponse');
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
