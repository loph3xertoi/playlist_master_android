import 'package:flutter/material.dart';

import 'basic_info.dart';

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
  late Animation<double> _menu_arrow_animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _menu_arrow_animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
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
    return Container(
      height: 40.0,
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        color: Color(0xFFF0E6E9),
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
          prefixIcon: GestureDetector(
            child: Ink(
              decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: CircleBorder(),
              ),
              child: IconButton(
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
                            backgroundImage:
                                AssetImage('assets/images/avatar.png'),
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
        ),
        onTap: _onSearchAreaPressed,
      ),
    );
  }
}
