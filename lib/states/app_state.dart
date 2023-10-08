import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
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

import '../config/user_info.dart';
import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/basic/basic_user.dart';
import '../entities/basic/basic_video.dart';
import '../entities/bilibili/bili_detail_fav_list.dart';
import '../entities/bilibili/bili_detail_resource.dart';
import '../entities/bilibili/bili_fav_list.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/bilibili/bili_user.dart';
import '../entities/dto/basic_pms_user_info_dto.dart';
import '../entities/dto/bili_links_dto.dart';
import '../entities/dto/paged_data_dto.dart';
import '../entities/dto/result.dart';
import '../entities/dto/updated_library_dto.dart';
import '../entities/netease_cloud_music/ncm_detail_playlist.dart';
import '../entities/netease_cloud_music/ncm_detail_song.dart';
import '../entities/netease_cloud_music/ncm_detail_video.dart';
import '../entities/netease_cloud_music/ncm_playlist.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/netease_cloud_music/ncm_user.dart';
import '../entities/netease_cloud_music/ncm_video.dart';
import '../entities/pms/pms_detail_library.dart';
import '../entities/pms/pms_detail_song.dart';
import '../entities/pms/pms_library.dart';
import '../entities/pms/pms_song.dart';
import '../entities/pms/pms_user.dart';
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
import '../utils/storage_manager.dart';

class MyAppState extends ChangeNotifier {
  /// JSESSIONID for user that has login.
  static String? cookie;

  /// Using mock data.
  bool _isUsingMockData = false;

  //// The current platform, 0 for pm server, 1 for qq music, 2 for netease music, 3 for bilibili.
  int _currentPlatform = 0;

  /// Whether in detail favlist page.
  bool _inDetailFavlistPage = false;

  /// Index of current opened resource in favlist.
  int? _currentResourceIndexInFavList;

  /// Whether the detail fav list is in search mode.
  bool _isDetailFavListPageInSearchMode = false;

  /// Whether is waiting searched result.
  bool _isSearching = false;

  /// The function to call when the keyword in search bar is submitted.
  void Function(String keyword)? onSearchBarSubmit;

  /// The controller of text field in search bar.
  TextEditingController? _searchTextEditingController;

  /// Search suggestions for bilibili.
  List<String> _searchSuggestions = [];

  /// Whether resource player is locked.
  bool _isResourcePlayerLocked = false;

  /// Whether resource player is full screen.
  bool _isFullScreen = false;

  /// Current playing sub resource in bilibili, can be BiliDetailResource or BiliSubPageOfResource.
  dynamic _currentPlayingSubResource;

  /// Subpage No of bili detail resource, represents the index of sub resource
  /// or episode in detail resource of bilibili.
  int _subPageNo = 1;

  /// Controller for better player.
  BetterPlayerController? _betterPlayerController;

  /// Store all sub resource's links dto in detail resource page.
  Map<String, BiliLinksDTO> _subResourcesLinks = {};

  /// Error message by fetch* function.
  String _errorMsg = '';

  /// Refresh detail library page.
  void Function(MyAppState appState)? _refreshDetailLibraryPage;

  /// Refresh detail fav list page.
  void Function(MyAppState appState)? _refreshDetailFavListPage;

  /// Refresh home page's libraries.
  Future<PagedDataDTO<BasicLibrary>?> Function(MyAppState, bool, [bool])?
      refreshLibraries;

  /// Whether there has more searched results.
  bool _hasMore = true;

  /// Total count of searched items.
  int _searchedCount = 0;

  // // Current page.
  // int _currentPage = 2;

  // // First page number.
  // int _firstPageNo = 1;

  // // Searching page size.
  // int _pageSize = 20;

  // // Total searched songs count.
  // int _totalSearchedSongs = 0;

  /// Searched resources, for bilibili.
  List<BiliResource> _searchedResources = [];

  /// Searched songs, for pms, qqmusic and ncm.
  List<BasicSong> _searchedSongs = [];

  /// Searching keyword.
  String? _keyword;

  /// Last video's vid.
  String lastVideoVid = '';

  /// The time when quit video.
  int videoSeekTime = 0;

  /// Dark mode.
  bool? _isDarkMode;

  /// Default image for cover.
  static const String defaultCoverImage =
      'https://img0.baidu.com/it/u=819122015,412168181&fm=253&fmt=auto&app=138&f=JPEG?w=320&h=320';
  // static const String defaultCoverImage =
  //     'https://www.worldwildlife.org/assets/structure/unique/logo-c562409bb6158bf64e5f8b1be066dbd5983d75f5ce7c9935a5afffbcc03f8e5d.png';

  static String defaultLibraryCover = kIsWeb
      ? API.convertImageUrl(
          'http://y.gtimg.cn/mediastyle/global/img/cover_playlist.png?max_age=31536000')
      : 'http://y.gtimg.cn/mediastyle/global/img/cover_playlist.png?max_age=31536000';

  /// Set true when init songs player for cover animation forward.
  bool _isFirstLoadSongsPlayer = false;

  /// Set true when init resources player for cover animation forward.
  bool _isFirstLoadResourcesPlayer = false;

  /// Current basic playing song.
  BasicSong? _currentSong;

  /// Current basic playing resource.
  BiliResource? _currentResource;

  /// Previous basic playing song.
  BasicSong? _prevSong;

  /// Previous basic playing resource.
  BiliResource? _prevResource;

  /// Current detail playing song.
  BasicSong? _currentDetailSong;

  /// Current detail playing resource.
  BiliDetailResource? _currentDetailResource;

  /// Is removing song from queue?
  bool _isRemovingSongFromQueue = false;

  /// Is removing resource from queue?
  bool _isRemovingResourceFromQueue = false;

  /// Whether the songs player page is opened.
  bool _isSongsPlayerPageOpened = false;

  /// Whether the resources player page is opened.
  bool _isResourcesPlayerPageOpened = false;

  /// Make sure songs player page pop once.
  bool _canSongsPlayerPagePop = false;

  /// Make sure resources player page pop once.
  bool _canResourcesPlayerPagePop = false;

  /// Whether removing song in queue, this should be true for updating the current song.
  bool _updatingSong = false;

  /// Whether removing resource in queue, this should be true for updating the current resource.
  bool _updatingResource = false;

  /// Current songs player.
  AudioPlayer? _songsPlayer;

  /// Current songs queue.
  List<BasicSong>? _songsQueue;

  /// Current bilibili resources queue.
  List<BiliResource>? _resourcesQueue;

  /// Raw songs of the library.
  List<BasicSong>? _rawSongsInLibrary;

  /// Raw resources of the fav list.
  List<BiliResource>? _rawResourcesInFavList;

  /// Define the songs audio source.
  ConcatenatingAudioSource? _songsAudioSource;

  /// Define the bilibili resources audio source.
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

  /// Volume of both players.
  double? _volume = 0.5;

  /// Speed of both players.
  double? _speed = 1.0;

  /// User playing mode, 0 for shuffle, 1 for repeat, 2 for repeat one.
  int _userPlayingMode = 1;

  /// Bilibili video playing mode.
  /// 0(Sub-Resource once): play current episode or sub resource once and then stop.
  /// 1(Sub-Resource repeat): play current episode or sub resource and then repeat.
  /// 2(Resource once): play all episodes or sub resources in this resource once and then stop.
  /// 3(Resource repeat): play all episodes or sub resources in this resource and then repeat.
  /// 4(Favlist once): play all resources in favlist once and then stop.
  /// 5(Favlist once (traverse episodes resource)): play all resources in favlist once and then stop,
  ///   traverse the episodes if current playing resource exists.
  /// 6(Favlist repeat): play all resources in favlist and then repeat.
  /// 7(Favlist repeat (traverse episodes resource)): play all resources in favlist and then repeat,
  ///   traverse the episodes if current playing resource exists.
  int _biliResourcePlayingMode = 0;

  /// Playing mode name for resource player in bilibili.
  List<String> _playingModeNames = [
    'Sub-Resource once',
    'Sub-Resource repeat',
    'Resource once',
    'Resource repeat',
    'Favlist once',
    'Favlist once (traverse episodes resource)',
    'Favlist repeat',
    'Favlist repeat (traverse episodes resource)',
  ];

  /// All icons corresponding to the playing mode.
  List<IconData> _playingModeIcons = [
    Icons.repeat_one_rounded,
    Icons.repeat_one_on_rounded,
    Icons.repeat_rounded,
    Icons.repeat_on_rounded,
    Icons.library_music_outlined,
    Icons.library_music_rounded,
    Icons.library_music_outlined,
    Icons.library_music_rounded,
  ];

  /// Current playing song in queue.
  int _currentPlayingSongInQueue = 0;

  /// Current playing resource in queue.
  int _currentPlayingResourceInQueue = 0;

  /// Cover rotating controller.
  AnimationController? _coverRotatingController;

  CarouselController _carouselController = CarouselController();

  /// Previous carousel index.
  int _prevCarouselIndex = 0;

  /// Current opened library, will change when navigate to similar song page.
  BasicLibrary? _openedLibrary;

  /// Raw opened library.
  BasicLibrary? _rawOpenedLibrary;

  /// Whether the songs player is playing songs.
  bool _isSongPlaying = false;

  /// Whether the resources player is playing resources.
  bool _isResourcePlaying = false;

  void Function(MyAppState appState)? get refreshDetailLibraryPage =>
      _refreshDetailLibraryPage;

  void Function(MyAppState appState)? get refreshDetailFavListPage =>
      _refreshDetailFavListPage;

  List<String> get playingModeNames => _playingModeNames;

  List<IconData> get playingModeIcons => _playingModeIcons;

  bool get inDetailFavlistPage => _inDetailFavlistPage;

  int? get currentResourceIndexInFavList => _currentResourceIndexInFavList;

  bool get isSearching => _isSearching;

  bool get isDetailFavListPageInSearchMode => _isDetailFavListPageInSearchMode;

  TextEditingController? get searchTextEditingController =>
      _searchTextEditingController;

  List<String> get searchSuggestions => _searchSuggestions;

  dynamic get currentPlayingSubResource => _currentPlayingSubResource;

  Map<String, BiliLinksDTO> get subResourcesLinks => _subResourcesLinks;

  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  String get errorMsg => _errorMsg;

  bool get hasMore => _hasMore;

  int get searchedCount => _searchedCount;

  // int get currentPage => _currentPage;

  // int get firstPageNo => _firstPageNo;

  // int get pageSize => _pageSize;

  // int get totalSearchedSongs => _totalSearchedSongs;

  int get subPageNo => _subPageNo;

  bool get isResourcePlayerLocked => _isResourcePlayerLocked;

  bool get isFullScreen => _isFullScreen;

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

  bool get isSongPlaying => _isSongPlaying;

  bool get isResourcePlaying => _isResourcePlaying;

  ConcatenatingAudioSource? get songsAudioSource => _songsAudioSource;

  ConcatenatingAudioSource? get resourcesAudioSource => _resourcesAudioSource;

  int get userPlayingMode => _userPlayingMode;

  int get biliResourcePlayingMode => _biliResourcePlayingMode;

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

  set inDetailFavlistPage(value) {
    _inDetailFavlistPage = value;
    notifyListeners();
  }

  set currentResourceIndexInFavList(index) {
    _currentResourceIndexInFavList = index;
    notifyListeners();
  }

  set refreshDetailLibraryPage(func) {
    _refreshDetailLibraryPage = func;
    notifyListeners();
  }

  set refreshDetailFavListPage(func) {
    _refreshDetailFavListPage = func;
    notifyListeners();
  }

  set isSearching(value) {
    _isSearching = value;
    notifyListeners();
  }

  set isDetailFavListPageInSearchMode(value) {
    _isDetailFavListPageInSearchMode = value;
    notifyListeners();
  }

  void resetSearchTextEditingController() {
    _searchTextEditingController = null;
  }

  set searchTextEditingController(controller) {
    _searchTextEditingController = controller;
    // notifyListeners();
  }

  set searchSuggestions(suggestions) {
    _searchSuggestions = List.from(suggestions);
    notifyListeners();
  }

  set isResourcePlayerLocked(bool value) {
    _isResourcePlayerLocked = value;
    notifyListeners();
  }

  set isFullScreen(bool value) {
    _isFullScreen = value;
    notifyListeners();
  }

  set currentPlayingSubResource(dynamic value) {
    _currentPlayingSubResource = value;
    notifyListeners();
  }

  set subPageNo(int value) {
    _subPageNo = value;
    notifyListeners();
  }

  void resetSubPageNo() {
    _subPageNo = 1;
  }

  void setSubPageNoWithoutNotify(value) {
    _subPageNo = value;
  }

  set betterPlayerController(BetterPlayerController? betterPlayerController) {
    _betterPlayerController = betterPlayerController;
    notifyListeners();
  }

  set hasMore(bool hasMore) {
    _hasMore = hasMore;
    notifyListeners();
  }

  set searchedCount(int count) {
    _searchedCount = count;
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

  void setCurrentPlatform(int value) {
    _currentPlatform = value;
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

  set biliResourcePlayingMode(mode) {
    _biliResourcePlayingMode = mode;
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
    _songsAudioSource!.clear();
    _songsPlayer!.dispose();
    _songsPlayer = null;
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
        throw UnsupportedError('Invalid playing mode: $_userPlayingMode');
      }

      /// Set the volume.
      await _songsPlayer!.setVolume(_volume!);

      /// Set the speed.
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
      songs = _songsQueue!.map((e) async {
        var url = kIsWeb
            ? Uri.parse(defaultCoverImage)
            : await getImageFileFromAssets(e.cover, _songsQueue!.indexOf(e));
        CacheManager cacheManager = MyHttp.myImageCacheManager;
        final file = await cacheManager.getSingleFile(
          url.toString(),
          headers: {
            'Cookie': MyAppState.cookie!,
            'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
          },
        );
        final artUri = Uri.file(file.path);
        return AudioSource.asset(
          e.songLink!,
          tag: MediaItem(
            // Specify a unique ID for each media item:
            id: Uuid().v1(),
            // artHeaders: {
            //   'Cookie': MyAppState.cookie!,
            //   'User-Agent':
            //       'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
            // },
            // Metadata to display in the notification:
            album: 'Album name',
            artist: e.singers.map((e) => e.name).join(', '),
            title: e.name,
            artUri: artUri,
          ),
        );
      }).toList();
    } else {
      for (BasicSong song in _songsQueue!) {
        if (song.songLink != null) {
          CacheManager cacheManager = MyHttp.myImageCacheManager;
          final file = await cacheManager.getSingleFile(
            song.cover,
            headers: {
              'Cookie': MyAppState.cookie!,
              'User-Agent':
                  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
            },
          );
          final artUri = Uri.file(file.path);
          songs.add(Future.value(LockCachingAudioSource(
            Uri.parse(song.songLink!),
            headers: {
              'Cookie': MyAppState.cookie!,
              'User-Agent':
                  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
            },
            tag: MediaItem(
              // Specify a unique ID for each media item:
              id: Uuid().v1(),
              // Metadata to display in the notification:
              album: 'Album name',
              artist: song.singers.map((e) => e.name).join(', '),
              title: song.name,
              artUri: artUri,
            ),
          )));
        }
      }
      if (_songsQueue!.isNotEmpty && songs.isEmpty) {
        if (_currentPlatform == 0) {
          for (var i = 0; i < _songsQueue!.length; i++) {
            PMSSong initialSong = _songsQueue![i] as PMSSong;
            CacheManager cacheManager = MyHttp.myImageCacheManager;
            final file = await cacheManager.getSingleFile(
              initialSong.cover,
              headers: {
                'Cookie': MyAppState.cookie!,
                'User-Agent':
                    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
              },
            );
            final artUri = Uri.file(file.path);
            songs.add(Future.value(ResolvingAudioSource(
              uniqueId: initialSong.id.toString(),
              resolveSoundUrl: (uniqueId) async {
                uniqueId = initialSong.id.toString();
                return Uri.parse(await fetchSongsLink([uniqueId], 0));
              },
              headers: {
                'Cookie': MyAppState.cookie!,
                'User-Agent':
                    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
              },
              tag: MediaItem(
                id: Uuid().v1(),
                album: 'Album name',
                artist: initialSong.singers.map((e) => e.name).join(', '),
                title: initialSong.name,
                artUri: artUri,
              ),
            )));
          }
        } else {
          throw 'Invalid platform';
        }
      }
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
    io.Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var filePath =
        '$tempPath/image_tmp_$index.png'; // image_tmp.png is dump file, can be anything
    return (await io.File(filePath).writeAsBytes(
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

  Future<int?> login(String email, String password) async {
    Map<String, Object> requestBody = {'email': email, 'password': password};
    final Uri url = Uri.https(API.host, API.login);
    var rawClient = http.Client();
    final client = RetryClient(rawClient);
    try {
      MyLogger.logger.i('Login...');
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Credentials': 'true',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          if (kIsWeb) {
            cookie = (result.data as Map)['cookie'];
          } else {
            cookie = response.headers['set-cookie'];
          }
          int userId = (result.data as Map)['id'];
          UserInfo.uid = userId.toString();
          StorageManager.saveData('uid', UserInfo.uid);
          StorageManager.saveData('cookie', cookie);
          return userId;
        } else {
          _errorMsg = result.message!;
          // MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<Map<String, Object>?> loginByGitHub(String authorizationUrl) async {
    final Uri url = Uri.parse(authorizationUrl);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Login by GitHub...');
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print(response.body.toString());
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          bool userExists = (result.data as Map)['userExists'] as bool;
          if (userExists) {
            if (kIsWeb) {
              cookie = (result.data as Map)['cookie'];
            } else {
              cookie = response.headers['set-cookie'];
            }
            int userId = (result.data as Map)['id'];
            UserInfo.uid = userId.toString();
            StorageManager.saveData('uid', UserInfo.uid);
            StorageManager.saveData('cookie', cookie);
            Map<String, Object> ret = {
              'id': userId,
              'userExists': userExists,
            };
            return ret;
          } else {
            Map<String, Object> ret = {
              'userExists': userExists,
            };
            return ret;
          }
        } else {
          _errorMsg = result.message!;
          // MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<Map<String, Object>?> loginByGoogle(String authorizationCode,
      [String? registrationCode]) async {
    Map<String, String> queryParameters = {'code': authorizationCode};
    if (registrationCode != null) {
      queryParameters['registrationCode'] = registrationCode;
    }
    final Uri url = Uri.https(API.host, API.googleRedirectUrl, queryParameters);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Login by Google...');
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print(response.body.toString());
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          bool userExists = (result.data as Map)['userExists'] as bool;
          if (userExists) {
            if (kIsWeb) {
              cookie = (result.data as Map)['cookie'];
            } else {
              cookie = response.headers['set-cookie'];
            }
            int userId = (result.data as Map)['id'];
            UserInfo.uid = userId.toString();
            StorageManager.saveData('uid', UserInfo.uid);
            StorageManager.saveData('cookie', cookie);
            Map<String, Object> ret = {
              'id': userId,
              'userExists': userExists,
            };
            return ret;
          } else {
            Map<String, Object> ret = {
              'userExists': userExists,
            };
            return ret;
          }
        } else {
          _errorMsg = result.message!;
          // MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<bool> updateCredential(
      String thirdId, String thirdCookie, int platform) async {
    String thirdAppName;
    if (platform == 1) {
      thirdAppName = 'QQ Music';
    } else if (platform == 2) {
      thirdAppName = 'Netease Cloud Music';
    } else if (platform == 3) {
      thirdAppName = 'BiliBili';
    } else {
      throw 'Invalid third app type';
    }
    Map<String, Object> requestBody = {
      'thirdId': thirdId,
      'thirdCookie': thirdCookie
    };
    final Uri url =
        Uri.https(API.host, API.credential, {'platform': platform.toString()});
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Updating third app\'s credential...');
      final response = await client.put(
        url,
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return false;
        } else {
          MyLogger.logger.i('Credential have been added in $thirdAppName');
          MyToast.showToast('Credential have been added in $thirdAppName');
          return true;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Send token for resetting password, need login first.
  Future<bool> forgotPassword() async {
    final Uri url = Uri.https(API.host, API.forgotPassword);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Forgot password...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return false;
        }
        return true;
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests, please retry in one minute.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Send token for binding email, need login first.
  Future<bool> bindEmail(String email) async {
    final Uri url = Uri.https(API.host, API.bindEmail, {'email': email});
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Bind email...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return false;
        }
        return true;
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests, please retry in one minute.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Send verify token without needing login first.
  Future<bool> sendVerifyToken(String email, int type) async {
    final Uri url = Uri.https(
        API.host, API.sendCode, {'email': email, 'type': type.toString()});
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Send verify token...');
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          MyLogger.logger.e(_errorMsg);
          return false;
        }
        return true;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests, please retry in one minute.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> logout() async {
    final Uri url = Uri.https(API.host, API.logout);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Logout...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return;
        }
        cookie = null;
        UserInfo.uid = '0';
        StorageManager.deleteData('cookie');
        StorageManager.deleteData('uid');
        StorageManager.deleteData('currentPlatform');
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<String?> register(String name, String email, String phoneNumber,
      String password, String registrationCode) async {
    Map<String, Object> requestBody = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'registrationCode': registrationCode,
    };
    final Uri url = Uri.https(API.host, API.register);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Register user...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return result.data.toString();
        } else {
          _errorMsg = result.message!;
          // MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<bool> verifyResetPassToken(
      String password, String repeatedPassword, String token) async {
    Map<String, Object> requestBody = {
      'password': password,
      'repeatedPassword': repeatedPassword,
      'token': token
    };
    final Uri url = Uri.https(API.host, API.verifyResetPass);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Verify token for resetting password...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return false;
        } else {
          return true;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<bool> verifyBindEmailToken(String email, String token) async {
    Map<String, Object> requestBody = {'email': email, 'token': token};
    final Uri url = Uri.https(API.host, API.verifyBindEmail);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Verify token for binding email...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return false;
        } else {
          return true;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return false;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<String?> verifyResetPasswordNologin(String password,
      String repeatedPassword, String token, String email) async {
    Map<String, Object> requestBody = {
      'password': password,
      'repeatedPassword': repeatedPassword,
      'email': email,
      'token': token
    };
    final Uri url = Uri.https(API.host, API.verifyTokenForResetPasswordNologin);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Verify token...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          // MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        } else {
          return result.data.toString();
        }
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<String?> verifySignUpNologin(
      String name,
      String email,
      String phoneNumber,
      String password,
      String token,
      String registrationCode) async {
    Map<String, Object> requestBody = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'token': token,
      'registrationCode': registrationCode,
    };
    final Uri url = Uri.https(API.host, API.verifyTokenForSignUpNologin);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Verify token...');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (!result.success) {
          _errorMsg = result.message!;
          // MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        } else {
          return result.data.toString();
        }
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<dynamic> getCookies() async {
    final Uri url = Uri.https(API.host, '/cookies');
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Get all cookies...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return decodedResponse;
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<BasicUser?> fetchUser(int platform) async {
    BasicUser Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      resolveJson = PMSUser.fromJson;
    } else if (platform == 1) {
      resolveJson = QQMusicUser.fromJson;
    } else if (platform == 2) {
      resolveJson = NCMUser.fromJson;
    } else if (platform == 3) {
      resolveJson = BiliUser.fromJson;
    } else {
      throw UnsupportedError('Invalid platform');
    }
    final Uri url = Uri.https(
      API.host,
      '${API.user}/${UserInfo.uid}',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Loading user information from network...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          Map<String, dynamic> user = decodedResponse['data'];
          return resolveJson(user);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<BasicPMSUserInfoDTO?> getBasicInfoOfLoginUser() async {
    final Uri url = Uri.https(API.host, API.basicUser);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Loading basic pms user information from network...');
      // final response = await client.get(url);
      print('cookie: $cookie');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          Map<String, dynamic> user = decodedResponse['data'];
          return BasicPMSUserInfoDTO.fromJson(user);
        } else {
          _errorMsg = result.message!;
          // MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        // MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        // MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        // MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      }
    } catch (e) {
      // MyToast.showToast('Exception thrown: $e');
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
      resolveJson = PMSLibrary.fromJson;
      params = {
        'id': UserInfo.uid,
        'pn': pn!,
        'ps': '20',
        'platform': platform.toString(),
      };
    } else if (platform == 1) {
      resolveJson = QQMusicPlaylist.fromJson;
      params = {
        'id': UserInfo.uid,
        'platform': platform.toString(),
      };
    } else if (platform == 2) {
      resolveJson = NCMPlaylist.fromJson;
      params = {
        'id': UserInfo.uid,
        'platform': platform.toString(),
      };
    } else if (platform == 3) {
      resolveJson = BiliFavList.fromJson;
      params = {
        'id': UserInfo.uid,
        'pn': pn!,
        'ps': '20',
        'biliPlatform': 'web',
        'type': '0',
        'platform': platform.toString(),
      };
    } else {
      throw UnsupportedError('Invalid platform');
    }
    final Uri url = Uri.https(
      API.host,
      API.libraries,
      params,
    );
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Loading libraries from network...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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
          return data;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      resolveJson = PMSDetailSong.fromJson as T Function(Map<String, dynamic>);
      url = Uri.https(
        API.host,
        '${API.detailSong}/${(song as PMSSong).id}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 1) {
      resolveJson =
          QQMusicDetailSong.fromJson as T Function(Map<String, dynamic>);
      url = Uri.https(
        API.host,
        '${API.detailSong}/${(song as QQMusicSong).songMid}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      resolveJson = NCMDetailSong.fromJson as T Function(Map<String, dynamic>);
      url = Uri.https(
        API.host,
        '${API.detailSong}/${(song as NCMSong).id}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 3) {
      resolveJson =
          BiliDetailResource.fromJson as T Function(Map<String, dynamic>);
      url = Uri.https(
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
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return resolveJson(decodedResponse['data']);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
    final Uri url = Uri.https(
      API.host,
      '${API.mvLink}/${vids.join(',')}',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Loading MVs link from network...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          var mvsLink = decodedResponse['data']!;
          return mvsLink.map((key, value) =>
              MapEntry<String, List<String>>(key, List<String>.from(value)));
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  /// Only used in bilibili now.
  Future<dynamic> fetchSongsLink(List<String> songIds, int platform) async {
    if (platform == 0) {
    } else if (platform == 1) {
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
    } else {
      throw UnsupportedError('Invalid platform');
    }
    final Uri url = Uri.https(
      API.host,
      '${API.songsLink}/${songIds.join(',')}',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Loading songs link from network...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          var songsLink = decodedResponse['data']!;
          if (platform == 0) {
            return songsLink;
          } else if (platform == 3) {
            BiliLinksDTO biliLinksDTO = BiliLinksDTO.fromJson(songsLink);
            return biliLinksDTO;
          } else {
            Map<String, dynamic>? songsMap = songsLink;
            // .map((key, value) => MapEntry<String, dynamic>(key, value));
            return songsMap;
          }
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      resolveJson = PMSDetailLibrary.fromJson;
      url = Uri.https(
        API.host,
        '${API.detailLibrary}/${(library as PMSLibrary).id}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 1) {
      resolveJson = QQMusicDetailPlaylist.fromJson;
      url = Uri.https(
        API.host,
        '${API.detailLibrary}/${(library as QQMusicPlaylist).tid}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      resolveJson = NCMDetailPlaylist.fromJson;
      url = Uri.https(
        API.host,
        '${API.detailLibrary}/${(library as NCMPlaylist).id}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 3) {
      resolveJson = BiliDetailFavList.fromJson;
      url = Uri.https(
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
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return resolveJson(decodedResponse['data']);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<PagedDataDTO<T>?> fetchSearchedSongs<T>(
      String keyword, int pageNo, int pageSize, int platform) async {
    PagedDataDTO<T> Function(Map<String, dynamic>) resolveJson;
    if (platform == 0) {
      if (!(kIsWeb || io.Platform.isAndroid || io.Platform.isIOS)) {
        MyToast.showToast('Not yet implement searching for pms songs');
        MyLogger.logger.e('Not yet implement searching for pms songs');
      }
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
    } else if (platform == 2) {
    } else if (platform == 3) {
    } else {
      throw UnsupportedError('Invalid platform');
    }
    resolveJson = PagedDataDTO<T>.fromJson;
    final Uri url = Uri.https(API.host, '${API.searchSong}/$keyword', {
      'pageNo': pageNo.toString(),
      'pageSize': pageSize.toString(),
      'platform': platform.toString(),
    });
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Searching items from network...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          PagedDataDTO<T> data = resolveJson(decodedResponse['data']);
          return data;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      int songType;
      if ((song as PMSSong).type == 1) {
        songType = 1;
      } else if (song.type == 2) {
        songType = 2;
      } else {
        throw 'Invalid song type';
      }
      if (songType == 1) {
        resolveJson = QQMusicSong.fromJson;
      } else {
        resolveJson = NCMSong.fromJson;
      }
      url = Uri.https(
        API.host,
        '${API.similarSongs}/${song.id}',
        {
          'songType': songType.toString(),
          'platform': platform.toString(),
        },
      );
    } else if (platform == 1) {
      resolveJson = QQMusicSong.fromJson;
      url = Uri.https(
        API.host,
        '${API.similarSongs}/${(song as QQMusicSong).songId}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      resolveJson = NCMSong.fromJson;
      url = Uri.https(
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
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          List<dynamic> jsonList = decodedResponse['data'];
          return jsonList.map<BasicSong>((e) => resolveJson(e)).toList();
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      url = Uri.https(
        API.host,
        '${API.detailMV}/${(video as QQMusicVideo).vid}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      resolveJson = NCMDetailVideo.fromJson;
      url = Uri.https(
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
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return resolveJson(decodedResponse['data']);
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      int songType = (song as PMSSong).type;
      if (songType == 1) {
        resolveJson = QQMusicVideo.fromJson;
      } else if (songType == 2) {
        resolveJson = NCMVideo.fromJson;
      } else {
        throw 'Invalid song type';
      }
      url = Uri.https(
        API.host,
        '${API.relatedMV}/${song.id}',
        {
          'songType': songType.toString(),
          'platform': platform.toString(),
        },
      );
    } else if (platform == 1) {
      resolveJson = QQMusicVideo.fromJson;
      url = Uri.https(
        API.host,
        '${API.relatedMV}/${(song as QQMusicSong).songId}',
        {
          'platform': platform.toString(),
        },
      );
    } else if (platform == 2) {
      resolveJson = NCMVideo.fromJson;
      url = Uri.https(
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
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          List<dynamic> jsonList = decodedResponse['data'];
          return jsonList
              .map<BasicVideo>((video) => resolveJson(video))
              .toList();
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
    } else if (platform == 1) {
    } else if (platform == 2) {
    } else if (platform == 3) {
    } else {
      throw UnsupportedError('Invalid platform');
    }
    final Uri url = Uri.https(
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
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Library created successfully');
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<Result?> updateLibrary(
      UpdatedLibraryDTO updatedLibrary, int platform) async {
    if (platform == 0) {
    } else if (platform == 1) {
      throw UnimplementedError('Not yet implement qqmusic platform');
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }
    final Uri url = Uri.https(
      API.host,
      API.updateLibrary,
      {
        'platform': platform.toString(),
      },
    );
    var request = http.MultipartRequest('PUT', url);
    request.headers['Cookie'] = cookie!;
    request.fields['id'] = updatedLibrary.id.toString();
    request.fields['name'] = updatedLibrary.name;
    // Map<String, String> requestBody = {};
    // requestBody.putIfAbsent('name', () => libraryName);
    if (updatedLibrary.intro != null) {
      // requestBody.putIfAbsent('intro', () => intro);
      request.fields['intro'] = updatedLibrary.intro!;
    }
    if (updatedLibrary.cover != null) {
      // requestBody.putIfAbsent('cover', () => cover.readAsBytes());
      request.files.add(updatedLibrary.cover!);
    }
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Updating library...');
      // final response = await client.put(
      //   url,
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(requestBody),
      // );
      final response = await request.send();
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(await response.stream.toBytes()))
                as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Library updated successfully');
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      if (libraries[0] is PMSLibrary) {
        librariesIds =
            libraries.map((library) => (library as PMSLibrary).id).join(",");
      } else {
        librariesIds = libraries
            .map((library) => (library as PMSDetailLibrary).id)
            .join(",");
      }
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
    final Uri url = Uri.https(
      API.host,
      '${API.deleteLibrary}/$librariesIds',
      {
        'platform': platform.toString(),
      },
    );
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Deleting libraries...');
      final response = await client.delete(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Delete libraries successfully');
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<Result?> addSongsToLibrary(List<BasicSong> songs, BasicLibrary library,
      bool isAddToPMSLibrary, int platform) async {
    Map<String, Object> requestBody;
    if (platform == 0) {
      int libraryId = (library as PMSLibrary).id;
      String songsIds = songs.map((e) {
        if (e is PMSSong) {
          return e.id;
        } else if (e is QQMusicSong) {
          return e.songMid;
        } else if (e is NCMSong) {
          return e.id;
        } else {
          throw 'Invalid song type';
        }
      }).join(',');
      String tid = libraryId.toString();
      requestBody = {
        'libraryId': libraryId.toString(),
        'songsIds': songsIds.toString(),
        'isAddToPMSLibrary': true,
        'tid': tid,
      };
    } else if (platform == 1) {
      if (isAddToPMSLibrary) {
        int libraryId = (library as PMSLibrary).id;
        String tid = libraryId.toString();
        List<Map<String, dynamic>> songJsonList =
            songs.map((song) => (song as QQMusicSong).toJson()).toList();
        requestBody = {
          'libraryId': libraryId.toString(),
          'songs': songJsonList,
          'isAddToPMSLibrary': isAddToPMSLibrary,
          'tid': tid,
        };
      } else {
        int dirId = (library as QQMusicPlaylist).dirId;
        String songsMid =
            songs.map((e) => (e as QQMusicSong).songMid).join(',');
        String tid = library.tid;
        requestBody = {
          'libraryId': dirId.toString(),
          'songsIds': songsMid,
          'isAddToPMSLibrary': isAddToPMSLibrary,
          'tid': tid,
        };
      }
    } else if (platform == 2) {
      if (isAddToPMSLibrary) {
        int libraryId = (library as PMSLibrary).id;
        String tid = libraryId.toString();
        List<Map<String, dynamic>> songJsonList =
            songs.map((song) => (song as NCMSong).toJson()).toList();
        requestBody = {
          'libraryId': libraryId.toString(),
          'songs': songJsonList,
          'isAddToPMSLibrary': isAddToPMSLibrary,
          'tid': tid,
        };
      } else {
        int id = (library as NCMPlaylist).id;
        String songIds = songs.map((e) => (e as NCMSong).id).join(',');
        String tid = id.toString();
        requestBody = {
          'libraryId': id.toString(),
          'songsIds': songIds,
          'isAddToPMSLibrary': isAddToPMSLibrary,
          'tid': tid,
        };
      }
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }
    final Uri url = Uri.https(
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
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      int id = (library as PMSLibrary).id;
      String ids = songs.map((e) => (e as PMSSong).id).join(',');
      url = Uri.https(
        API.host,
        API.removeSongsFromLibrary,
        {
          'libraryId': id.toString(),
          'songsId': ids,
          'tid': id.toString(),
          'platform': platform.toString(),
        },
      );
    } else if (platform == 1) {
      int dirId = (library as QQMusicPlaylist).dirId;
      String tid = library.tid;
      String songsId = songs.map((e) => (e as QQMusicSong).songId).join(',');
      url = Uri.https(
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
      url = Uri.https(
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
      final response = await client.delete(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Songs removed from ${library.name}');
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      String ids = songs.map((e) => (e as PMSSong).id).join(',');
      int srcLibraryId = (srcLibrary as PMSLibrary).id;
      int dstLibraryId = (dstLibrary as PMSLibrary).id;
      String srcTid = srcLibraryId.toString();
      String dstTid = dstLibraryId.toString();
      url = Uri.https(
        API.host,
        API.moveSongsToOtherLibrary,
        {
          'platform': platform.toString(),
        },
      );
      requestBody = {
        'songsId': ids,
        'fromLibrary': srcLibraryId.toString(),
        'toLibrary': dstLibraryId.toString(),
        'fromTid': srcTid,
        'toTid': dstTid,
      };
    } else if (platform == 1) {
      String songsId = songs.map((e) => (e as QQMusicSong).songId).join(',');
      int srcDirId = (srcLibrary as QQMusicPlaylist).dirId;
      int dstDirId = (dstLibrary as QQMusicPlaylist).dirId;
      String srcTid = srcLibrary.tid;
      String dstTid = dstLibrary.tid;
      url = Uri.https(
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
      url = Uri.https(
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
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Songs moved successfully');
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
      bool isFavoriteSearchedResource,
      bool isAddToPMSLibrary,
      String favListsIds,
      int platform) async {
    Map<String, Object> requestBody;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      throw UnimplementedError('Not yet implement qqmusic platform');
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      if (isAddToPMSLibrary) {
        requestBody = {
          'libraryId': favListsIds,
          'resources': resources,
          'isAddToPMSLibrary': isAddToPMSLibrary,
          'tid': favListsIds,
        };
      } else {
        String resourcesIds;
        if (isFavoriteSearchedResource) {
          resourcesIds = resources.map((e) => '${e.id}').join(',');
        } else {
          resourcesIds = resources.map((e) => '${e.id}:${e.type}').join(',');
        }
        requestBody = {
          'libraryId': favListsIds,
          'songsIds': resourcesIds,
          'biliSourceFavListId': biliSourceFavListId,
          'isAddToPMSLibrary': isAddToPMSLibrary,
          'isFavoriteSearchedResource': isFavoriteSearchedResource,
          'tid': favListsIds,
        };
      }
    } else {
      throw UnsupportedError('Invalid platform');
    }
    final Uri url = Uri.https(
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
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      int id = (favList as BiliFavList).id;
      String tid = favList.id.toString();
      String resourcesIds = resources.map((e) => '${e.id}:${e.type}').join(',');
      url = Uri.https(
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
      final response = await client.delete(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Resources removed from ${favList.name}');
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
    } else if (platform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (platform == 3) {
      String resourcesIds = resources.map((e) => '${e.id}:${e.type}').join(',');
      int srcFavListId = (srcFavList as BiliFavList).id;
      int dstFavListId = (dstFavList as BiliFavList).id;
      String srcTid = srcFavListId.toString();
      String dstTid = dstFavListId.toString();
      url = Uri.https(
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
        headers: {'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        Result result = Result.fromJson(decodedResponse);
        if (result.success) {
          MyToast.showToast('Resources moved successfully');
          return result;
        } else {
          _errorMsg = result.message!;
          MyToast.showToast(_errorMsg);
          MyLogger.logger.e(_errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return null;
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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
    final Uri url = Uri.https(API.host, API.getBiliSplashScreenImage);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Loading bilibili splash screen images...');
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return '';
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return '';
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
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

  Future<List<String>> getSearchSuggestions(String keyword) async {
    final Uri url = Uri.https(API.host, '${API.getSearchSuggestions}/$keyword');
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger
          .i('Fetching search suggestions for $keyword in bilibili...');
      final response = await client.get(url, headers: {'Cookie': cookie!});
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        int resultCode = decodedResponse['code'];
        var resultJson = decodedResponse['result'];
        if (resultCode == 0 && resultJson.isNotEmpty) {
          List<dynamic> tagsList = decodedResponse['result']['tag'];
          List<String> tags = tagsList.map<String>((e) => e['name']).toList();
          return tags;
        } else {
          if (resultCode != 0) {
            _errorMsg = decodedResponse['message'] ??
                'Failed to fetch suggestions for $keyword in bilibili.';
            MyToast.showToast(_errorMsg);
          } else {
            _errorMsg = 'No suggestions for $keyword in bilibili.';
          }
          MyLogger.logger.e(_errorMsg);
          return [];
        }
      } else if (response.statusCode == 401) {
        _errorMsg = 'Cookie expired, please login again.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return [];
      } else if (response.statusCode == 403) {
        _errorMsg = 'You don\'t have access for this operation.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return [];
      } else if (response.statusCode == 429) {
        _errorMsg = 'Too many requests.';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return [];
      } else {
        _errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(_errorMsg);
        MyLogger.logger.e(_errorMsg);
        return [];
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
