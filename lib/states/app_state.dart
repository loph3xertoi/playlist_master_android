import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
import '../entities/basic/basic_song.dart';
import '../entities/basic/basic_user.dart';
import '../entities/basic/basic_video.dart';
import '../entities/bilibili/bili_detail_fav_list.dart';
import '../entities/bilibili/bili_detail_resource.dart';
import '../entities/bilibili/bili_fav_list.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/bilibili/bili_user.dart';
import '../entities/dto/paged_data.dart';
import '../entities/dto/result.dart';
import '../entities/netease_cloud_music/ncm_detail_playlist.dart';
import '../entities/netease_cloud_music/ncm_detail_song.dart';
import '../entities/netease_cloud_music/ncm_detail_video.dart';
import '../entities/netease_cloud_music/ncm_playlist.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/netease_cloud_music/ncm_user.dart';
import '../entities/netease_cloud_music/ncm_video.dart';
import '../entities/qq_music/qqmusic_detail_playlist.dart';
import '../entities/qq_music/qqmusic_detail_song.dart';
import '../entities/qq_music/qqmusic_detail_video.dart';
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
  // Store all sub resource's links in detail resource page.
  Map<String, Map<String, Map<String, String>>> _subResourcesLinks = {};

  // Error message by fetch* function.
  String _errorMsg = '';

  // Refresh detail library page.
  void Function(MyAppState appState)? refreshDetailLibraryPage;

  // Refresh detail fav list page.
  void Function(MyAppState appState)? refreshDetailFavListPage;

  // Refresh home page's libraries.
  Future<PagedDataDTO<BasicLibrary>?> Function(MyAppState, bool)?
      refreshLibraries;

  // Whether there has more searched results.
  bool? _hasMore;

  // // Current page.
  // int _currentPage = 2;

  // // First page number.
  // int _firstPageNo = 1;

  // // Searching page size.
  // int _pageSize = 20;

  // // Total searched songs count.
  // int _totalSearchedSongs = 0;

  // Searched resources, for bilibili.
  List<BiliResource> _searchedResources = [];

  // Searched songs, for pms, qqmusic and ncm.
  List<BasicSong> _searchedSongs = [];

  // Searching keyword.
  String? _keyword;

  // Last video's vid.
  String lastVideoVid = '';

  // The time when quit video.
  int videoSeekTime = 0;

  // Dark mode.
  bool? _isDarkMode;

  // Using mock data.
  bool _isUsingMockData = false;

  /// The current platform, 0 for pm server, 1 for qq music, 2 for netease music, 3 for bilibili.
  int _currentPlatform = 3;

  // Default image for cover.
  static const String defaultCoverImage =
      'https://img0.baidu.com/it/u=819122015,412168181&fm=253&fmt=auto&app=138&f=JPEG?w=320&h=320';
  // static const String defaultCoverImage =
  //     'https://www.worldwildlife.org/assets/structure/unique/logo-c562409bb6158bf64e5f8b1be066dbd5983d75f5ce7c9935a5afffbcc03f8e5d.png';

  static const String defaultLibraryCover =
      'http://y.gtimg.cn/mediastyle/global/img/cover_playlist.png?max_age=31536000';

  // Set true when init songs player for cover animation forward.
  bool _isFirstLoadSongsPlayer = false;

  // Set true when init resources player for cover animation forward.
  bool _isFirstLoadResourcesPlayer = false;

  // Current basic playing song.
  BasicSong? _currentSong;

  // Current basic playing resource.
  BiliResource? _currentResource;

  // Previous basic playing song.
  BasicSong? _prevSong;

  // Previous basic playing resource.
  BiliResource? _prevResource;

  // Current detail playing song.
  BasicSong? _currentDetailSong;

  // Current detail playing resource.
  BiliDetailResource? _currentDetailResource;

  // Is removing song from queue?
  bool _isRemovingSongFromQueue = false;

  // Is removing resource from queue?
  bool _isRemovingResourceFromQueue = false;

  // Whether the songs player page is opened.
  bool _isSongsPlayerPageOpened = false;

  // Whether the resources player page is opened.
  bool _isResourcesPlayerPageOpened = false;

  // Make sure songs player page pop once.
  bool _canSongsPlayerPagePop = false;

  // Make sure resources player page pop once.
  bool _canResourcesPlayerPagePop = false;

  // Whether removing song in queue, this should be true for updating the current song.
  bool _updatingSong = false;

  // Whether removing resource in queue, this should be true for updating the current resource.
  bool _updatingResource = false;

  // Current songs player.
  AudioPlayer? _songsPlayer;

  // Current resources player.
  AudioPlayer? _resourcesPlayer;

  // Current songs queue.
  List<BasicSong>? _songsQueue;

  // Current bilibili resources queue.
  List<BiliResource>? _resourcesQueue;

  // Raw songs of the library.
  List<BasicSong>? _rawSongsInLibrary;

  // Raw resources of the fav list.
  List<BiliResource>? _rawResourcesInFavList;

  // Define the songs audio source.
  ConcatenatingAudioSource? _songsAudioSource;

  // Define the bilibili resources audio source.
  ConcatenatingAudioSource? _resourcesAudioSource;

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get songsPlayerPositionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _songsPlayer?.createPositionStream(
              minPeriod: Duration(milliseconds: 1),
              maxPeriod: Duration(milliseconds: 1),
            ) ??
            Stream.empty(),
        _songsPlayer?.bufferedPositionStream ?? Stream.empty(),
        _songsPlayer?.durationStream ?? Stream.empty(),
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get resourcesPlayerPositionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _resourcesPlayer?.createPositionStream(
              minPeriod: Duration(milliseconds: 1),
              maxPeriod: Duration(milliseconds: 1),
            ) ??
            Stream.empty(),
        _resourcesPlayer?.bufferedPositionStream ?? Stream.empty(),
        _resourcesPlayer?.durationStream ?? Stream.empty(),
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  // Volume of both players.
  double? _volume = 1.0;

  // Speed of both players.
  double? _speed = 1.0;

  // User playing mode, 0 for shuffle, 1 for repeat, 2 for repeat one.
  int _userPlayingMode = 1;

  // Current playing song in queue.
  int _currentPlayingSongInQueue = 0;

  // Current playing resource in queue.
  int _currentPlayingResourceInQueue = 0;

  // Cover rotating controller.
  AnimationController? _coverRotatingController;

  CarouselController _carouselController = CarouselController();

  // Previous carousel index.
  int _prevCarouselIndex = 0;

  // Current opened library, will change when navigate to similar song page.
  BasicLibrary? _openedLibrary;

  // Raw opened library.
  BasicLibrary? _rawOpenedLibrary;

  // Whether the songs player is playing songs.
  bool _isSongPlaying = false;

  // Whether the resources player is playing resources.
  bool _isResourcePlaying = false;

  Map<String, Map<String, Map<String, String>>> get subResourcesLinks =>
      _subResourcesLinks;

  String get errorMsg => _errorMsg;

  bool? get hasMore => _hasMore;

  // int get currentPage => _currentPage;

  // int get firstPageNo => _firstPageNo;

  // int get pageSize => _pageSize;

  // int get totalSearchedSongs => _totalSearchedSongs;

  List<BiliResource> get searchedResources => _searchedResources;

  List<BasicSong> get searchedSongs => _searchedSongs;

  String? get keyword => _keyword;

  /// The current platform, 0 for pm server, 1 for qq music, 2 for netease music, 3 for bilibili.
  int get currentPlatform => _currentPlatform;

  bool? get isDarkMode => _isDarkMode;

  int get prevCarouselIndex => _prevCarouselIndex;

  BasicSong? get prevSong => _prevSong;

  BiliResource? get prevResource => _prevResource;

  BasicSong? get currentDetailSong => _currentDetailSong;

  BiliDetailResource? get currentDetailResource => _currentDetailResource;

  bool get isUsingMockData => _isUsingMockData;

  bool get isFirstLoadSongsPlayer => _isFirstLoadSongsPlayer;

  bool get isFirstLoadResourcesPlayer => _isFirstLoadResourcesPlayer;

  BasicSong? get currentSong => _currentSong;

  BiliResource? get currentResource => _currentResource;

  AnimationController? get coverRotatingController => _coverRotatingController;

  bool get isRemovingSongFromQueue => _isRemovingSongFromQueue;

  bool get isRemovingResourceFromQueue => _isRemovingResourceFromQueue;

  bool get isSongsPlayerPageOpened => _isSongsPlayerPageOpened;

  bool get isResourcesPlayerPageOpened => _isResourcesPlayerPageOpened;

  bool get canSongsPlayerPagePop => _canSongsPlayerPagePop;

  bool get canResourcesPlayerPagePop => _canResourcesPlayerPagePop;

  bool get updatingSong => _updatingSong;

  bool get updatingResource => _updatingResource;

  CarouselController get carouselController => _carouselController;

  AudioPlayer? get songsPlayer => _songsPlayer;

  AudioPlayer? get resourcesPlayer => _resourcesPlayer;

  bool get isSongPlaying => _isSongPlaying;

  bool get isResourcePlaying => _isResourcePlaying;

  ConcatenatingAudioSource? get songsAudioSource => _songsAudioSource;

  ConcatenatingAudioSource? get resourcesAudioSource => _resourcesAudioSource;

  int get userPlayingMode => _userPlayingMode;

  BasicLibrary? get openedLibrary => _openedLibrary;

  BasicLibrary? get rawOpenedLibrary => _rawOpenedLibrary;

  bool get isSongsQueueEmpty => _songsQueue?.isEmpty ?? true;

  bool get isResourcesQueueEmpty => _resourcesQueue?.isEmpty ?? true;

  List<BasicSong>? get songsQueue => _songsQueue;

  List<BiliResource>? get resourcesQueue => _resourcesQueue;

  List<BasicSong>? get rawSongsInLibrary => _rawSongsInLibrary;

  List<BiliResource>? get rawResourcesInFavList => _rawResourcesInFavList;

  int? get currentPlayingSongInQueue => _currentPlayingSongInQueue;

  int? get currentPlayingResourceInQueue => _currentPlayingResourceInQueue;

  double? get volume => _volume;

  double? get speed => _speed;

  // set currentPage(int value) {
  //   _currentPage = value;
  //   notifyListeners();
  // }

  // set totalSearchedSongs(int value) {
  //   _totalSearchedSongs = value;
  //   notifyListeners();
  // }

  set hasMore(bool? hasMore) {
    _hasMore = hasMore;
    notifyListeners();
  }

  set searchedResources(List<BiliResource> resources) {
    _searchedResources = List.from(resources);
    notifyListeners();
  }

  set searchedSongs(List<BasicSong> songs) {
    _searchedSongs = List.from(songs);
    notifyListeners();
  }

  set keyword(String? value) {
    _keyword = value;
    notifyListeners();
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

  set rawSongsInLibrary(value) {
    _rawSongsInLibrary = List.from(value);
    notifyListeners();
  }

  set rawResourcesInFavList(value) {
    _rawResourcesInFavList = List.from(value);
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

  set prevResource(BiliResource? value) {
    _prevResource = value;
    notifyListeners();
  }

  set currentDetailSong(BasicSong? value) {
    _currentDetailSong = value;
    notifyListeners();
  }

  set currentDetailResource(BiliDetailResource? value) {
    _currentDetailResource = value;
    notifyListeners();
  }

  set isUsingMockData(bool value) {
    _isUsingMockData = value;
    notifyListeners();
  }

  set isFirstLoadSongsPlayer(bool value) {
    _isFirstLoadSongsPlayer = value;
    notifyListeners();
  }

  set isFirstLoadResourcesPlayer(bool value) {
    _isFirstLoadResourcesPlayer = value;
    notifyListeners();
  }

  set currentSong(BasicSong? value) {
    _currentSong = value;
    notifyListeners();
  }

  set currentResource(BiliResource? value) {
    _currentResource = value;
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

  set isRemovingResourceFromQueue(bool value) {
    _isRemovingResourceFromQueue = value;
    notifyListeners();
  }

  set isSongsPlayerPageOpened(bool value) {
    _isSongsPlayerPageOpened = value;
    notifyListeners();
  }

  set isResourcesPlayerPageOpened(bool value) {
    _isResourcesPlayerPageOpened = value;
    notifyListeners();
  }

  set canSongsPlayerPagePop(bool value) {
    _canSongsPlayerPagePop = value;
    notifyListeners();
  }

  set canResourcesPlayerPagePop(bool value) {
    _canResourcesPlayerPagePop = value;
    notifyListeners();
  }

  set updatingSong(bool value) {
    _updatingSong = value;
    notifyListeners();
  }

  set updatingResource(bool value) {
    _updatingResource = value;
    notifyListeners();
  }

  set songsPlayer(AudioPlayer? songsPlayer) {
    _songsPlayer = songsPlayer;
    notifyListeners();
  }

  set resourcesPlayer(AudioPlayer? resourcesPlayer) {
    _resourcesPlayer = resourcesPlayer;
    notifyListeners();
  }

  set isSongPlaying(isSongPlaying) {
    _isSongPlaying = isSongPlaying;
    notifyListeners();
  }

  set isResourcePlaying(isResourcePlaying) {
    _isResourcePlaying = isResourcePlaying;
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

  set songsQueue(songsQueue) {
    _songsQueue = List.from(songsQueue);
    notifyListeners();
  }

  set resourcesQueue(resourcesQueue) {
    _resourcesQueue = List.from(resourcesQueue);
    notifyListeners();
  }

  set currentPlayingSongInQueue(index) {
    _currentPlayingSongInQueue = index;
    notifyListeners();
  }

  set currentPlayingResourceInQueue(index) {
    _currentPlayingResourceInQueue = index;
    notifyListeners();
  }

  void disposeSongsPlayer() {
    _songsQueue = [];
    _currentDetailSong = null;
    _currentPlayingSongInQueue = 0;
    _currentSong = null;
    _prevSong = null;
    _isSongPlaying = false;
    _songsPlayer!.stop();
    _songsPlayer!.dispose();
    _songsPlayer = null;
    _songsAudioSource!.clear();
    _isSongsPlayerPageOpened = false;
    _canSongsPlayerPagePop = false;
  }

  Future<void> initSongsPlayer() async {
    _songsPlayer = AudioPlayer();

    // Try to load audio from a source and catch any errors.
    try {
      _songsAudioSource = await initSongsAudioSource();

      // Listen to errors during playback.
      _songsPlayer!.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        },
      );

      await _songsPlayer!.setAudioSource(_songsAudioSource!,
          initialIndex: _currentPlayingSongInQueue,
          initialPosition: Duration.zero);

      // Set the playing mode of the player.
      if (_userPlayingMode == 0) {
        await _songsPlayer!.setShuffleModeEnabled(true);
        await _songsPlayer!.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 1) {
        await _songsPlayer!.setShuffleModeEnabled(false);
        await _songsPlayer!.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 2) {
        await _songsPlayer!.setShuffleModeEnabled(false);
        await _songsPlayer!.setLoopMode(LoopMode.one);
      } else {
        throw UnsupportedError('Invalid playing mode');
      }

      // Set the volume.
      await _songsPlayer!.setVolume(_volume!);
      // Set the speed.
      await _songsPlayer!.setSpeed(_speed!);

      // TODO: fix bug: when remove song in library, this function will also be called.
      _songsPlayer!.positionDiscontinuityStream.listen((discontinuity) {
        // _coverRotatingController!.value = 0;
        if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance &&
            !_updatingSong &&
            !_isRemovingSongFromQueue) {
          if (_userPlayingMode == 0) {
            currentPlayingSongInQueue = discontinuity.event.currentIndex;
            currentSong = _songsQueue![currentPlayingSongInQueue!];
            prevCarouselIndex = currentPlayingSongInQueue!;
            // _carouselController.animateToPage(_songsPlayer!.effectiveIndices!
            // .indexOf(_currentPlayingSongInQueue!));
          } else if (_userPlayingMode == 1) {
            currentPlayingSongInQueue =
                discontinuity.event.currentIndex ?? _currentPlayingSongInQueue;
            currentSong = _songsQueue![currentPlayingSongInQueue!];
            prevCarouselIndex = currentPlayingSongInQueue!;
            // _carouselController.animateToPage(_currentPlayingSongInQueue!);
          } else {
            return;
          }
        }
      });
      _songsPlayer!.playingStream.listen((playing) {
        isSongPlaying = playing;
      });
    } catch (e) {
      print('Error init songs player: $e');
      throw Exception('Error init songs player: $e');
    }
  }

  Future<ConcatenatingAudioSource?> initSongsAudioSource() async {
    List<AudioSource> queueList;
    List<Future<AudioSource>> songs = [];
    if (isUsingMockData) {
      songs = _songsQueue!
          .map((e) async => AudioSource.asset(
                e.songLink,
                tag: MediaItem(
                  // Specify a unique ID for each media item:
                  id: Uuid().v1(),
                  // Metadata to display in the notification:
                  album: 'Album name',
                  artist: e.singers.map((e) => e.name).join(', '),
                  title: e.name,
                  artUri: await getImageFileFromAssets(
                      e.cover, _songsQueue!.indexOf(e)),
                ),
              ))
          .toList();
    } else {
      songs = _songsQueue!
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

  void disposeResourcesPlayer() {
    _resourcesQueue = [];
    _currentDetailResource = null;
    _currentPlayingResourceInQueue = 0;
    _currentResource = null;
    _prevResource = null;
    _isResourcePlaying = false;
    _resourcesPlayer!.stop();
    _resourcesPlayer!.dispose();
    _resourcesPlayer = null;
    _resourcesAudioSource!.clear();
    _isResourcesPlayerPageOpened = false;
    _canResourcesPlayerPagePop = false;
  }

  Future<void> initResourcesPlayer() async {
    _resourcesPlayer = AudioPlayer();

    // Try to load audio from a source and catch any errors.
    try {
      _resourcesAudioSource = await initResourcesAudioSource();

      // Listen to errors during playback.
      _resourcesPlayer!.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        },
      );

      await _resourcesPlayer!.setAudioSource(_resourcesAudioSource!,
          initialIndex: _currentPlayingResourceInQueue,
          initialPosition: Duration.zero);

      // Set the playing mode of the player.
      if (_userPlayingMode == 0) {
        await _resourcesPlayer!.setShuffleModeEnabled(true);
        await _resourcesPlayer!.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 1) {
        await _resourcesPlayer!.setShuffleModeEnabled(false);
        await _resourcesPlayer!.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 2) {
        await _resourcesPlayer!.setShuffleModeEnabled(false);
        await _resourcesPlayer!.setLoopMode(LoopMode.one);
      } else {
        throw UnsupportedError('Invalid playing mode');
      }

      // Set the volume.
      await _resourcesPlayer!.setVolume(_volume!);
      // Set the speed.
      await _resourcesPlayer!.setSpeed(_speed!);

      // TODO: fix bug: when remove resource in fav list, this function will also be called.
      _resourcesPlayer!.positionDiscontinuityStream.listen((discontinuity) {
        // _coverRotatingController!.value = 0;
        if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance &&
            !_updatingResource &&
            !_isRemovingResourceFromQueue) {
          if (_userPlayingMode == 0) {
            currentPlayingResourceInQueue = discontinuity.event.currentIndex;
            currentResource = _resourcesQueue![currentPlayingResourceInQueue!];
            prevCarouselIndex = currentPlayingResourceInQueue!;
          } else if (_userPlayingMode == 1) {
            currentPlayingResourceInQueue = discontinuity.event.currentIndex ??
                _currentPlayingResourceInQueue;
            currentResource = _resourcesQueue![currentPlayingResourceInQueue!];
            prevCarouselIndex = currentPlayingResourceInQueue!;
            // _carouselController.animateToPage(_currentPlayingResourceInQueue!);
          } else {
            return;
          }
        }
      });
      _resourcesPlayer!.playingStream.listen((playing) {
        isResourcePlaying = playing;
      });
    } catch (e) {
      print('Error init resources player: $e');
      throw Exception('Error init resources player: $e');
    }
  }

  Future<ConcatenatingAudioSource?> initResourcesAudioSource() async {
    List<AudioSource> queueList;
    List<Future<AudioSource>> resources = [];
    if (isUsingMockData) {
      // resources = _resourcesQueue!
      //     .map((e) async => AudioSource.asset(
      //           e.songLink,
      //           tag: MediaItem(
      //             // Specify a unique ID for each media item:
      //             id: Uuid().v1(),
      //             // Metadata to display in the notification:
      //             album: 'Album name',
      //             artist: e.singers.map((e) => e.name).join(', '),
      //             title: e.name,
      //             artUri: await getImageFileFromAssets(
      //                 e.cover, _songsQueue!.indexOf(e)),
      //           ),
      //         ))
      //     .toList();
      throw UnimplementedError(
          'Not yet implemenet mock data for bilibili resources player');
    } else {
      // Fetch the resource links.
      // 1. Fetch detail resources.
      BiliResource resource = _resourcesQueue![_currentPlayingResourceInQueue];
      BiliDetailResource? detailResource =
          await fetchDetailSong<BiliDetailResource>(resource, _currentPlatform);
      // 2. Fetch links.
      Map<String, dynamic>? linksMap = await fetchSongsLink(
          ['${detailResource!.bvid}:${detailResource.cid}'], _currentPlatform);
      Map<String, String> audios = (linksMap?['audio'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toString()));
      String link = audios['30251'] ??
          audios['30250'] ??
          audios['30280'] ??
          audios['30232'] ??
          audios['30216']!;

      // TODO: change the key of the cached audio to reuse the audio, as the url may be changed.
      LockCachingAudioSource resourceAudioSource = LockCachingAudioSource(
        Uri.parse(link),
        headers: {
          'Referer': 'https://www.bilibili.com',
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
        },
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: Uuid().v1(),
          // Metadata to display in the notification:
          album: detailResource.title,
          artist: detailResource.upperName,
          title: detailResource.subpages![0].partName,
          artUri: Uri.parse(detailResource.cover),
          genre: detailResource.dynamicLabels,
          duration: Duration(seconds: detailResource.duration),
        ),
      );
      queueList = [resourceAudioSource];
    }

    return ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the queue items
      children: queueList,
    );
  }

  void removeSongInQueue(int index) {
    if (_songsQueue?.isNotEmpty ?? false) {
      _songsQueue!.removeAt(index);
    }
    notifyListeners();
  }

  void removeResourceInQueue(int index) {
    if (_resourcesQueue?.isNotEmpty ?? false) {
      _resourcesQueue!.removeAt(index);
    }
    notifyListeners();
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

  Future<BasicUser?> fetchUser(int platform) async {
    BasicUser Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicUser.fromJson;
    } else if (platform == 2) {
      resolveJson = NCMUser.fromJson;
    } else if (platform == 3) {
      resolveJson = BiliUser.fromJson;
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          Map<String, dynamic> user = decodedResponse['data'];
          return Future.value(resolveJson(user));
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<PagedDataDTO<BasicLibrary>?> fetchLibraries(int platform,
      [String? pn]) async {
    BasicLibrary Function(Map<String, dynamic>) resolveJson;
    Map<String, dynamic>? params;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = QQMusicPlaylist.fromJson;
      params = {
        'id': API.uid,
        'platform': platform.toString(),
      };
    } else if (platform == 2) {
      resolveJson = NCMPlaylist.fromJson;
      params = {
        'id': API.uid,
        'platform': platform.toString(),
      };
    } else if (platform == 3) {
      resolveJson = BiliFavList.fromJson;
      params = {
        'id': API.uid,
        'pn': pn!,
        'ps': '20',
        'biliPlatform': 'web',
        'type': '0',
        'platform': platform.toString(),
      };
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(
      API.host,
      API.libraries,
      params,
    );
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading libraries from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          var jsonList = decodedResponse['data'];
          int count = jsonList['count'];
          bool hasMore = jsonList['hasMore'];
          List<dynamic> librariesList = jsonList['list'];
          List<BasicLibrary>? list =
              librariesList.map<BasicLibrary>((e) => resolveJson(e)).toList();
          PagedDataDTO<BasicLibrary> data =
              PagedDataDTO<BasicLibrary>(count, list, hasMore);
          return Future.value(data);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<T?>? fetchDetailSong<T>(dynamic song, int platform) async {
    T Function(Map<String, dynamic>) resolveJson;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson =
          QQMusicDetailSong.fromJson as T Function(Map<String, dynamic>);
      url = Uri.http(
        API.host,
        '${API.detailSong}/${(song as QQMusicSong).songMid}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      resolveJson = NCMDetailSong.fromJson as T Function(Map<String, dynamic>);
      url = Uri.http(
        API.host,
        '${API.detailSong}/${(song as NCMSong).id}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 3) {
      resolveJson =
          BiliDetailResource.fromJson as T Function(Map<String, dynamic>);
      url = Uri.http(
        API.host,
        '${API.detailSong}/${(song as BiliResource).bvid}',
        {
          'platform': platform.toString(),
        },
      );
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading detail song from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return Future.value(resolveJson(decodedResponse['data']));
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  /// DON'T USE. TODO: Make a uniform result in different platforms.
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          var mvsLink = decodedResponse['data']!;
          return Future.value(mvsLink.map((key, value) =>
              MapEntry<String, List<String>>(key, List<String>.from(value))));
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  /// Not usedbug.
  Future<Map<String, dynamic>?> fetchSongsLink(
      List<String> songIds, int platform) async {
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          var songsLink = decodedResponse['data']!;
          Map<String, dynamic>? songsMap = songsLink;
          // .map((key, value) => MapEntry<String, dynamic>(key, value));
          return Future.value(songsMap);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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
    BasicLibrary library,
    int platform, {
    String? pn,
    String? ps,
    String? type,
    String? keyword,
    String? order,
    String? range,
  }) async {
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
      resolveJson = NCMDetailPlaylist.fromJson;
      url = Uri.http(
        API.host,
        '${API.detailLibrary}/${(library as NCMPlaylist).id}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 3) {
      resolveJson = BiliDetailFavList.fromJson;
      url = Uri.http(
        API.host,
        '${API.detailLibrary}/${(library as BiliFavList).id}',
        {
          'pn': pn!,
          'ps': ps ?? '20',
          'type': type ?? '0',
          'keyword': keyword,
          'order': order,
          'range': range,
          'platform': platform.toString(),
        },
      );
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading detail library from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return Future.value(resolveJson(decodedResponse['data']));
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<PagedDataDTO?> fetchSearchedSongs(
      String keyword, int pageNo, int pageSize, int platform) async {
    PagedDataDTO Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      resolveJson = PagedDataDTO<QQMusicSong>.fromJson;
    } else if (platform == 2) {
      resolveJson = PagedDataDTO<NCMSong>.fromJson;
    } else if (platform == 3) {
      resolveJson = PagedDataDTO<BiliResource>.fromJson;
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final Uri url = Uri.http(API.host, '${API.searchSong}/$keyword', {
      'pageNo': pageNo.toString(),
      'pageSize': pageSize.toString(),
      'platform': platform.toString(),
    });
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Searching songs from network...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          PagedDataDTO data = resolveJson(decodedResponse['data']);
          return Future.value(data);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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
      resolveJson = NCMSong.fromJson;
      url = Uri.http(
        API.host,
        '${API.similarSongs}/${(song as NCMSong).id}',
        {
          'platform': platform.toString(),
        },
      );
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          List<dynamic> jsonList = decodedResponse['data'];
          return Future.value(
              jsonList.map<BasicSong>((e) => resolveJson(e)).toList());
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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
      resolveJson = NCMDetailVideo.fromJson;
      url = Uri.http(
        API.host,
        '${API.detailMV}/${(video as NCMVideo).id}',
        {
          'platform': platform.toString(),
        },
      );
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return Future.value(resolveJson(decodedResponse['data']));
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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
      resolveJson = NCMVideo.fromJson;
      url = Uri.http(
        API.host,
        '${API.relatedMV}/${(song as NCMSong).id}',
        {
          'mvId': song.mvId?.toString(),
          'limit': '50',
          'platform': platform.toString(),
        },
      );
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          List<dynamic> jsonList = decodedResponse['data'];
          return Future.value(
              jsonList.map<BasicVideo>((video) => resolveJson(video)).toList());
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> createLibrary(
    String libraryName,
    int platform, [
    String? intro,
    int? privacy,
    String? cover,
  ]) async {
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
    } else if (platform == 2) {
    } else if (platform == 3) {
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
    Map<String, String> requestBody = {};
    requestBody.putIfAbsent('name', () => libraryName);

    // Only used in bilibili platform.
    if (intro != null) {
      requestBody.putIfAbsent('intro', () => intro);
    }
    if (privacy != null) {
      requestBody.putIfAbsent('privacy', () => privacy.toString());
    }
    if (cover != null) {
      requestBody.putIfAbsent('cover', () => cover);
    }
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Creating library...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Library created successfully');
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> deleteLibraries(
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
      if (libraries[0] is NCMPlaylist) {
        librariesIds =
            libraries.map((library) => (library as NCMPlaylist).id).join(",");
      } else {
        librariesIds = libraries
            .map((library) => (library as NCMDetailPlaylist).id)
            .join(",");
      }
    } else if (platform == 3) {
      if (libraries[0] is BiliFavList) {
        librariesIds =
            libraries.map((library) => (library as BiliFavList).id).join(",");
      } else {
        librariesIds = libraries
            .map((library) => (library as BiliDetailFavList).id)
            .join(",");
      }
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Delete libraries successfully');
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> addSongsToLibrary(
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
      int id = (library as NCMPlaylist).id;
      String songIds = songs.map((e) => (e as NCMSong).id).join(',');
      String tid = id.toString();
      requestBody = {
        'libraryId': id.toString(),
        'songsId': songIds,
        'tid': tid,
      };
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> removeSongsFromLibrary(
      List<BasicSong> songs, BasicLibrary library, int platform) async {
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      int dirId = (library as QQMusicPlaylist).dirId;
      String tid = library.tid;
      String songsId = songs.map((e) => (e as QQMusicSong).songId).join(',');
      url = Uri.http(
        API.host,
        API.removeSongsFromLibrary,
        {
          'libraryId': dirId.toString(),
          'songsId': songsId,
          'tid': tid,
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      int id = (library as NCMPlaylist).id;
      String tid = library.id.toString();
      String songsId = songs.map((e) => (e as NCMSong).id).join(',');
      url = Uri.http(
        API.host,
        API.removeSongsFromLibrary,
        {
          'libraryId': id.toString(),
          'songsId': songsId,
          'tid': tid,
          'platform': platform.toString(),
        },
      );
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Songs removed from ${library.name}');
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> moveSongsToOtherLibrary(
    List<BasicSong> songs,
    BasicLibrary srcLibrary,
    BasicLibrary dstLibrary,
    int platform,
  ) async {
    Map<String, Object> requestBody;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
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
      String songsId = songs.map((e) => (e as NCMSong).id).join(',');
      int srcLibraryId = (srcLibrary as NCMPlaylist).id;
      int dstLibraryId = (dstLibrary as NCMPlaylist).id;
      String srcTid = srcLibraryId.toString();
      String dstTid = dstLibraryId.toString();
      url = Uri.http(
        API.host,
        API.moveSongsToOtherLibrary,
        {
          'platform': platform.toString(),
        },
      );
      requestBody = {
        'songsId': songsId,
        'fromLibrary': srcLibraryId.toString(),
        'toLibrary': dstLibraryId.toString(),
        'fromTid': srcTid,
        'toTid': dstTid,
      };
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Songs moved successfully');
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> addResourcesToFavList(
      List<BiliResource> resources,
      int biliSourceFavListId,
      String isFavoriteSearchedResource,
      String favListsIds,
      int platform) async {
    Map<String, Object> requestBody;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      throw UnimplementedError('Not yet implement qqmusic platform');
      // int dirId = (library as QQMusicPlaylist).dirId;
      // String songsMid = songs.map((e) => (e as QQMusicSong).songMid).join(',');
      // String tid = library.tid;
      // requestBody = {
      //   'libraryId': dirId.toString(),
      //   'songsId': songsMid,
      //   'tid': tid,
      // };
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
      // int id = (library as NCMPlaylist).id;
      // String songIds = songs.map((e) => (e as NCMSong).id).join(',');
      // String tid = id.toString();
      // requestBody = {
      //   'libraryId': id.toString(),
      //   'songsId': songIds,
      //   'tid': tid,
      // };
    } else if (platform == 3) {
      String resourcesIds = resources.map((e) => '${e.id}:${e.type}').join(',');
      requestBody = {
        'libraryId': favListsIds,
        'songsId': resourcesIds,
        'biliSourceFavListId': biliSourceFavListId,
        'isFavoriteSearchedResource': isFavoriteSearchedResource,
        'tid': favListsIds,
      };
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
      MyLogger.logger.i('Adding resources to fav list...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> removeResourcesFromFavList(
      List<BiliResource> resources, BasicLibrary favList, int platform) async {
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      throw UnimplementedError('Not yet implement qqmusic platform');
      // int dirId = (library as QQMusicPlaylist).dirId;
      // String tid = library.tid;
      // String songsId = songs.map((e) => (e as QQMusicSong).songId).join(',');
      // url = Uri.http(
      //   API.host,
      //   API.removeSongsFromLibrary,
      //   {
      //     'libraryId': dirId.toString(),
      //     'songsId': songsId,
      //     'tid': tid,
      //     'platform': platform.toString(),
      //   },
      // );
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
      // int id = (library as NCMPlaylist).id;
      // String tid = library.id.toString();
      // String songsId = songs.map((e) => (e as NCMSong).id).join(',');
      // url = Uri.http(
      //   API.host,
      //   API.removeSongsFromLibrary,
      //   {
      //     'libraryId': id.toString(),
      //     'songsId': songsId,
      //     'tid': tid,
      //     'platform': platform.toString(),
      //   },
      // );
    } else if (platform == 3) {
      int id = (favList as BiliFavList).id;
      String tid = favList.id.toString();
      String resourcesIds = resources.map((e) => '${e.id}:${e.type}').join(',');
      url = Uri.http(
        API.host,
        API.removeSongsFromLibrary,
        {
          'libraryId': id.toString(),
          'songsId': resourcesIds,
          'tid': tid,
          'platform': platform.toString(),
        },
      );
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Removing resources from fav list...');
      final response = await client.delete(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Resources removed from ${favList.name}');
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<Result?> moveResourcesToOtherFavList(
    List<BiliResource> resources,
    BasicLibrary srcFavList,
    BasicLibrary dstFavList,
    int platform,
  ) async {
    Map<String, Object> requestBody;
    Uri? url;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      throw UnimplementedError('Not yet implement qqmusic platform');
      // String songsId = songs.map((e) => (e as QQMusicSong).songId).join(',');
      // int srcDirId = (srcLibrary as QQMusicPlaylist).dirId;
      // int dstDirId = (dstLibrary as QQMusicPlaylist).dirId;
      // String srcTid = srcLibrary.tid;
      // String dstTid = dstLibrary.tid;
      // url = Uri.http(
      //   API.host,
      //   API.moveSongsToOtherLibrary,
      //   {
      //     'platform': platform.toString(),
      //   },
      // );
      // requestBody = {
      //   'songsId': songsId,
      //   'fromLibrary': srcDirId.toString(),
      //   'toLibrary': dstDirId.toString(),
      //   'fromTid': srcTid,
      //   'toTid': dstTid,
      // };
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
      // String songsId = songs.map((e) => (e as NCMSong).id).join(',');
      // int srcLibraryId = (srcLibrary as NCMPlaylist).id;
      // int dstLibraryId = (dstLibrary as NCMPlaylist).id;
      // String srcTid = srcLibraryId.toString();
      // String dstTid = dstLibraryId.toString();
      // url = Uri.http(
      //   API.host,
      //   API.moveSongsToOtherLibrary,
      //   {
      //     'platform': platform.toString(),
      //   },
      // );
      // requestBody = {
      //   'songsId': songsId,
      //   'fromLibrary': srcLibraryId.toString(),
      //   'toLibrary': dstLibraryId.toString(),
      //   'fromTid': srcTid,
      //   'toTid': dstTid,
      // };
    } else if (platform == 3) {
      String resourcesIds = resources.map((e) => '${e.id}:${e.type}').join(',');
      int srcFavListId = (srcFavList as BiliFavList).id;
      int dstFavListId = (dstFavList as BiliFavList).id;
      String srcTid = srcFavListId.toString();
      String dstTid = dstFavListId.toString();
      url = Uri.http(
        API.host,
        API.moveSongsToOtherLibrary,
        {
          'platform': platform.toString(),
        },
      );
      requestBody = {
        'songsId': resourcesIds,
        'fromLibrary': srcFavListId.toString(),
        'toLibrary': dstFavListId.toString(),
        'fromTid': srcTid,
        'toTid': dstTid,
      };
    } else {
      throw UnsupportedError('Invalid platform');
    }

    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Moving resources to other fav list...');
      final response = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Resources moved successfully');
          return Future.value(result);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
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

  Future<String> getBiliSplashScreenImage() async {
    final Uri url = Uri.https('app.bilibili.com', '/x/v2/splash/brand/list', {
      'appkey': '1d8b6e7d45233436',
      'ts': '0',
      'sign': '78a89e153cd6231a4a4d55013aa063ce',
    });
    final client = RetryClient(http.Client());

    try {
      MyLogger.logger.i('Loading bilibili splash screen iamges...');
      final response = await client.get(url);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        int resultCode = decodedResponse['code'];
        if (resultCode == 0) {
          List<dynamic> splashScreenMapList = decodedResponse['data']['list'];
          List<String> splashScreenlist =
              splashScreenMapList.map<String>((e) => e['thumb']).toList();
          Random random = Random();
          int index = random.nextInt(splashScreenlist.length);
          return splashScreenlist[index];
        } else {
          _errorMsg = decodedResponse['message'];
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return '';
        }
      } else {
        _errorMsg = 'Response error: $decodedResponse';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return '';
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
