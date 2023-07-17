import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_song.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_paged_songs.dart';
import '../entities/basic/basic_song.dart';
import '../entities/qq_music/qqmusic_paged_songs.dart';
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
  late int _platform;
  late List<BasicSong?> _searchedSongs;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _platform = state.currentPlatform;
    _searchedSongs = state.searchedSongs;
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
      appState.currentPage = 2;
      if (searchString != '') {
        appState.searchingString = searchString;
        BasicPagedSongs? pagedSongs = await appState.fetchSearchedSongs(
            searchString, appState.firstPageNo, appState.pageSize, _platform);
        if (pagedSongs != null) {
          appState.totalSearchedSongs = pagedSongs.total;
          if (_platform == 1) {
            appState.searchedSongs = (pagedSongs as QQMusicPagedSongs).songs;
          } else {
            throw Exception('Only imeplement qq music platform');
          }
        }
      }
    } else if (widget.inDetailLibraryPage) {
      if (searchString != '') {
        appState.searchingString = searchString;
        if (_platform == 1) {
          appState.searchedSongs = appState.rawQueue!
              .where((e) =>
                  (e as QQMusicSong).name.contains(searchString) ||
                  e.singers.any((singer) => singer.name.contains(searchString)))
              .toList();
        } else {
          throw Exception('Only imeplement qq music platform');
        }
      } else {
        appState.searchedSongs = appState.rawQueue!;
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
    // final mySearchState = context.watch<MySearchState>();
    // bool isSearching = mySearchState.isSearching;
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 40.0,
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        color: colorScheme.secondary,
      ),
      child: TextField(
        controller: _textEditingController,
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
                        appState.totalSearchedSongs = 0;
                        appState.currentPage = 2;
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
                            backgroundImage: isUsingMockData
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
