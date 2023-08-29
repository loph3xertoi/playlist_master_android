import 'dart:ui' as ui show BoxHeightStyle;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import 'basic_info.dart';
import 'custom_selection_handler.dart';

class MySearchBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> myScaffoldKey;
  final bool notInHomepage;
  final bool inDetailLibraryPage;

  MySearchBar({
    required this.myScaffoldKey,
    required this.notInHomepage,
    required this.inDetailLibraryPage,
  });

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  bool _searchBarFocused = false;
  late int _currentPlatform;
  late bool _isUsingMockData;
  late List<BasicSong?> _searchedSongs;
  late List<BiliResource?> _searchedResources;
  late MyAppState _appState;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _appState = state;
    state.onSearchBarSubmit = _onSubmitted;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _textEditingController = TextEditingController();
    state.searchTextEditingController = _textEditingController;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _appState.resetSearchTextEditingController();
    _animationController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchIconPressed(MyAppState appState) async {
    if (widget.notInHomepage) {
      _onSubmitted(_textEditingController.text);
      _focusNode.unfocus();
    } else {
      Navigator.pushNamed(context, '/search_page');
    }
  }

  void _onSearchAreaPressed() {
    if (widget.notInHomepage) {
    } else {
      Navigator.pushNamed(context, '/search_page');
    }
    if (_appState.isDetailFavListPageInSearchMode) {
      return;
    }
    _searchBarFocused = true;
    _appState.keyword = null;
    _searchedSongs = [];
    _appState.searchedSongs = [];
    _searchedResources = [];
    _appState.searchedResources = [];
    _appState.searchedCount = 0;
    if (_appState.searchSuggestions.isEmpty) {
      if (_currentPlatform == 3 &&
          widget.notInHomepage &&
          !widget.inDetailLibraryPage) {
        _getSearchSuggestion(_textEditingController.text);
      }
    }
  }

  void _onSubmitted(String keyword) async {
    _appState.isSearching = true;
    _focusNode.unfocus();
    _searchBarFocused = false;
    keyword = keyword.trim();
    print(keyword);
    if (widget.notInHomepage && !widget.inDetailLibraryPage) {
      // Only search once per keyword, more resources of this keyword should be fetched by drag down the list in search page.
      if (keyword != '' && _appState.keyword != keyword) {
        _appState.keyword = keyword;
        dynamic pagedDataDTO;
        if (_currentPlatform == 0) {
          throw UnimplementedError('Not yet implement pms platform');
        } else if (_currentPlatform == 1) {
          pagedDataDTO = await _appState.fetchSearchedSongs<QQMusicSong>(
              keyword, 1, 20, _currentPlatform);
        } else if (_currentPlatform == 2) {
          pagedDataDTO = await _appState.fetchSearchedSongs<NCMSong>(
              keyword, 1, 20, _currentPlatform);
        } else if (_currentPlatform == 3) {
          pagedDataDTO = await _appState.fetchSearchedSongs<BiliResource>(
              keyword, 1, 20, _currentPlatform);
        } else {
          throw UnsupportedError('Invalid platform');
        }

        if (pagedDataDTO != null) {
          setState(() {
            _appState.hasMore = pagedDataDTO.hasMore;
            _appState.searchedCount = pagedDataDTO.count;
            var list = pagedDataDTO.list;
            if (_currentPlatform == 0) {
              throw UnimplementedError('Not yet implement pms platform');
            } else if (_currentPlatform == 1) {
              _searchedSongs.clear();
              _searchedSongs.addAll(list);
            } else if (_currentPlatform == 2) {
              _searchedSongs.clear();
              _searchedSongs.addAll(list);
            } else if (_currentPlatform == 3) {
              _searchedResources.clear();
              _searchedResources.addAll(list);
            } else {
              throw UnsupportedError('Invalid platform');
            }
          });
        }
      }
    } else if (widget.inDetailLibraryPage) {
      if (keyword != '') {
        _appState.keyword = keyword;
        if (_currentPlatform == 0) {
          throw UnimplementedError('Not yet implement pms platform');
        } else if (_currentPlatform == 1) {
          _appState.searchedSongs = _appState.rawSongsInLibrary!
              .where((e) =>
                  (e as QQMusicSong).name.contains(keyword) ||
                  e.singers.any((singer) => singer.name.contains(keyword)))
              .toList();
        } else if (_currentPlatform == 2) {
          _appState.searchedSongs = _appState.rawSongsInLibrary!
              .where((e) =>
                  (e as NCMSong).name.contains(keyword) ||
                  e.singers.any((singer) => singer.name.contains(keyword)))
              .toList();
        } else if (_currentPlatform == 3) {
          _appState.searchedResources = _appState.rawResourcesInFavList!
              .where((e) =>
                  e.title.contains(keyword) || e.upperName.contains(keyword))
              .toList();
          _appState.isDetailFavListPageInSearchMode = true;
        } else {
          throw UnsupportedError('Invalid platform');
        }
      } else {
        _appState.searchedSongs = _appState.rawSongsInLibrary!;
        _appState.searchedResources = _appState.rawResourcesInFavList!;
        _appState.isDetailFavListPageInSearchMode = false;
      }
    }
    _appState.isSearching = false;
  }

  void _onMenuIconPressed() {
    widget.myScaffoldKey.currentState?.openDrawer();
  }

  void _onBackIconPressed() {
    _appState.keyword = null;
    _searchedSongs = [];
    _appState.searchedSongs = [];
    _searchedResources = [];
    _appState.searchedResources = [];
    _appState.searchedCount = 0;
    _appState.searchSuggestions = [];
    _appState.refreshLibraries!(_appState, false);
    Navigator.pop(context);
  }

  void _onAvatarPressed() {
    showDialog(context: context, builder: (context) => BasicInfo());
  }

  void _getSearchSuggestion(String keyword) async {
    if (keyword == '') {
      _appState.searchSuggestions = [];
      _appState.searchedResources = [];
      _appState.searchedResources = [];
      _appState.searchedCount = 0;
      _appState.keyword = null;
      return;
    }
    var suggestions = await _appState.getSearchSuggestions(keyword);
    _appState.searchSuggestions = suggestions;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
    _currentPlatform = appState.currentPlatform;
    _isUsingMockData = appState.isUsingMockData;
    _searchedSongs = appState.searchedSongs;
    _searchedResources = appState.searchedResources;
    return Container(
      height: 40.0,
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        color: colorScheme.secondary,
      ),
      child: Theme(
        data: _currentPlatform == 3
            ? ThemeData(
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Color(0xFFBB5A7D),
                  selectionColor: Color(0xFFB75674),
                  selectionHandleColor: Color(0xFFEC6F92),
                ),
              )
            : Theme.of(context),
        child: TextField(
          selectionControls: _currentPlatform == 3
              ? CustomColorSelectionHandle(Color(0xFFEC6F92))
              : null,
          controller: _textEditingController,
          focusNode: _focusNode,
          textAlignVertical: TextAlignVertical.top,
          enabled: true,
          readOnly: widget.notInHomepage ? false : true,
          style: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSecondary,
          ),
          selectionHeightStyle: ui.BoxHeightStyle.max,
          onTap: _onSearchAreaPressed,
          enableInteractiveSelection: _searchBarFocused ||
              widget.inDetailLibraryPage ||
              _currentPlatform != 3,
          onSubmitted: (value) {
            _onSubmitted(value);
          },
          onChanged: _currentPlatform == 3 &&
                  widget.notInHomepage &&
                  !widget.inDetailLibraryPage
              ? (value) {
                  _getSearchSuggestion(value);
                }
              : null,
          contextMenuBuilder: (context, editableTextState) {
            final List<ContextMenuButtonItem> buttonItems =
                editableTextState.contextMenuButtonItems;
            return AdaptiveTextSelectionToolbar(
              anchors: editableTextState.contextMenuAnchors,
              children: [
                ...buttonItems.map<Widget>((buttonItem) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: buttonItem.onPressed,
                      child: Ink(
                        padding: EdgeInsets.all(8.0),
                        color: colorScheme.primary,
                        child: Text(
                          CupertinoTextSelectionToolbarButton.getButtonLabel(
                              context, buttonItem),
                          style: textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList()
              ],
            );
          },
          decoration: InputDecoration(
            alignLabelWithHint: true,
            floatingLabelAlignment: FloatingLabelAlignment.center,
            hintText: _currentPlatform != 3
                ? widget.inDetailLibraryPage
                    ? 'Search Playlists'
                    : 'Search Musics'
                : widget.inDetailLibraryPage
                    ? 'Search Favlists'
                    : 'Search Resources',
            hintStyle: textTheme.titleMedium,
            prefixIcon: GestureDetector(
              child: Ink(
                decoration: ShapeDecoration(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  color: colorScheme.tertiary,
                  icon: widget.notInHomepage
                      ? Icon(Icons.arrow_back_rounded)
                      : Icon(Icons.menu_rounded),
                  onPressed: widget.notInHomepage
                      ? () {
                          appState.searchedSongs = [];
                          appState.searchedResources = [];
                          // appState.totalSearchedSongs = 0;
                          // appState.currentPage = 2;
                          _onBackIconPressed();
                        }
                      : _onMenuIconPressed,
                ),
              ),
            ),
            suffixIcon: GestureDetector(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Ink(
                    decoration: ShapeDecoration(
                      color: Colors.transparent,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      color: colorScheme.tertiary,
                      icon: Icon(Icons.search_rounded),
                      onPressed: () {
                        _onSearchIconPressed(appState);
                      },
                    ),
                  ),
                  !widget.notInHomepage
                      ? Ink(
                          decoration: ShapeDecoration(
                            color: Colors.transparent,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            // No padding.
                            padding: EdgeInsets.zero,
                            icon: CircleAvatar(
                              radius: 15.0,
                              backgroundImage: _isUsingMockData
                                  ? Image.asset('assets/images/avatar.png')
                                      .image
                                  : CachedNetworkImageProvider(
                                      MyAppState.defaultCoverImage,
                                      cacheManager: MyHttp.myImageCacheManager,
                                    ),
                              // : Image.network(MyAppState.defaultCoverImage)
                              //     .image,
                            ),
                            onPressed: _onAvatarPressed,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            // Set the border width to 0.
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.0),
          ),
        ),
      ),
    );
  }
}
