import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:playlistmaster/http/my_http.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/widgets/basic_info.dart';
import 'package:provider/provider.dart';

class MySearchBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> myScaffoldKey;
  final bool notInHomepage;
  final bool inPlaylistDetailPage;

  MySearchBar({
    required this.myScaffoldKey,
    required this.notInHomepage,
    required this.inPlaylistDetailPage,
  });

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchIconPressed() {
    _onSearchAreaPressed();
  }

  void _onSearchAreaPressed() {
    if (widget.notInHomepage) {
      print('searching...');
    } else {
      Navigator.pushNamed(context, '/search');
    }
  }

  void _onMenuIconPressed() {
    widget.myScaffoldKey.currentState?.openDrawer();
  }

  void _onBackIconPressed() {
    Navigator.pop(context);
  }

  void _onAvatarPressed() {
    // AlertDialog alert = AlertDialog(
    //   title: Text('Avatar'),
    // );
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
        textAlignVertical: TextAlignVertical.top,
        enabled: true,
        readOnly: widget.notInHomepage ? false : true,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          floatingLabelAlignment: FloatingLabelAlignment.center,
          hintText:
              widget.inPlaylistDetailPage ? 'Search Playlist' : 'Search Music',
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
                    ? _onBackIconPressed
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
                    onPressed: _onSearchIconPressed,
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
      ),
    );
  }
}
