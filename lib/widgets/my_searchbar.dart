import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../states/app_state.dart';
import 'basic_info.dart';

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
  late int _currentPlatform;
  late bool _isUsingMockData;
  late List<BasicSong?> _searchedSongs;
  late List<BiliResource?> _searchedResources;
  MyAppState? _appState;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchIconPressed(MyAppState appState) async {
    if (widget.notInHomepage) {
      _onSubmitted(_textEditingController.text, appState);
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
  }

  void _onSubmitted(String searchString, MyAppState appState) async {
    searchString = searchString.trim();
    print(searchString);
    if (widget.notInHomepage && !widget.inDetailLibraryPage) {
      // Only search once per keyword, more resources of this keyword should be fetched by drag down the list in search page.
      if (searchString != '' && appState.keyword != searchString) {
        appState.keyword = searchString;
        var pagedDataDTO = await appState.fetchSearchedSongs(
            searchString, 1, 20, _currentPlatform);
        if (pagedDataDTO != null) {
          setState(() {
            appState.hasMore = pagedDataDTO.hasMore;
            var list = pagedDataDTO.list;
            if (_currentPlatform == 0) {
              throw UnimplementedError('Not yet implement pms platform');
            } else if (_currentPlatform == 1) {
              _searchedSongs = list as List<QQMusicSong>;
            } else if (_currentPlatform == 2) {
              _searchedSongs = list as List<NCMSong>;
            } else if (_currentPlatform == 3) {
              _searchedResources = list as List<BiliResource>;
            } else {
              throw UnsupportedError('Invalid platform');
            }
          });
        }
      }
    } else if (widget.inDetailLibraryPage) {
      if (searchString != '') {
        appState.keyword = searchString;
        if (_currentPlatform == 0) {
          throw UnimplementedError('Not yet implement pms platform');
        } else if (_currentPlatform == 1) {
          appState.searchedSongs = appState.rawSongsInLibrary!
              .where((e) =>
                  (e as QQMusicSong).name.contains(searchString) ||
                  e.singers.any((singer) => singer.name.contains(searchString)))
              .toList();
        } else if (_currentPlatform == 2) {
          appState.searchedSongs = appState.rawSongsInLibrary!
              .where((e) =>
                  (e as NCMSong).name.contains(searchString) ||
                  e.singers.any((singer) => singer.name.contains(searchString)))
              .toList();
        } else if (_currentPlatform == 3) {
          throw UnimplementedError('Not yet implement bilibili platform');
        } else {
          throw UnsupportedError('Invalid platform');
        }
      } else {
        appState.searchedSongs = appState.rawSongsInLibrary!;
      }
    }
  }

  void _onMenuIconPressed() {
    widget.myScaffoldKey.currentState?.openDrawer();
  }

  void _onBackIconPressed() {
    _searchedSongs.clear();
    Navigator.pop(context);
  }

  void _onAvatarPressed() {
    showDialog(context: context, builder: (context) => BasicInfo());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
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
      child: TextField(
        controller: _textEditingController,
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
        focusNode: _focusNode,
        textAlignVertical: TextAlignVertical.top,
        enabled: true,
        cursorColor: colorScheme.onPrimary,
        readOnly: widget.notInHomepage ? false : true,
        style: textTheme.titleMedium!.copyWith(
          color: colorScheme.onSecondary,
        ),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          floatingLabelAlignment: FloatingLabelAlignment.center,
          hintText:
              widget.inDetailLibraryPage ? 'Search Playlist' : 'Search Music',
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
                // icon: AnimatedIcon(
                //   icon: AnimatedIcons.menu_arrow,
                //   progress: _animationController,
                // ),
                onPressed: widget.notInHomepage
                    ? () {
                        appState.searchedSongs.clear();
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
                                ? Image.asset('assets/images/avatar.png').image
                                : CachedNetworkImageProvider(
                                    MyAppState.defaultCoverImage,
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
        onTap: _onSearchAreaPressed,
        onSubmitted: (value) {
          _onSubmitted(value, appState);
        },
      ),
    );
  }
}
