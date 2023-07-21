import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class MySideDrawer extends StatefulWidget {
  @override
  State<MySideDrawer> createState() => _MySideDrawerState();
}

class _MySideDrawerState extends State<MySideDrawer> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMenuTile(String title, IconData icon, bool isSelected) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      title: Text(
        title,
        style: textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.bold,
          fontStyle: isSelected ? FontStyle.italic : FontStyle.normal,
          // fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      onTap: () {
        if (title == 'Home') {
          _selectedIndex = 0;
        } else if (title == 'Profile') {
          _selectedIndex = 1;
        } else if (title == 'Settings') {
          _selectedIndex = 2;
        }
        _onItemTapped(_selectedIndex);
      },
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SizedBox(
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                // color: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      accountName: Text(
                        'Daw Loph',
                        style: textTheme.labelMedium,
                      ),
                      accountEmail: Text(
                        'loph3xertoi@gmail.com',
                        style: textTheme.labelMedium,
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: AssetImage(
                          currentPlatform == 0
                              ? 'assets/images/pm_round.png'
                              : currentPlatform == 1
                                  ? 'assets/images/qqmusic.png'
                                  : currentPlatform == 2
                                      ? 'assets/images/netease.png'
                                      : 'assets/images/bilibili.png',
                        ),
                      ),
                      otherAccountsPictures: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            currentPlatform == 0
                                ? 'assets/images/qqmusic.png'
                                : currentPlatform == 1
                                    ? 'assets/images/netease.png'
                                    : currentPlatform == 2
                                        ? 'assets/images/bilibili.png'
                                        : 'assets/images/qqmusic.png',
                          ),
                        ),
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            currentPlatform == 0
                                ? 'assets/images/netease.png'
                                : currentPlatform == 1
                                    ? 'assets/images/bilibili.png'
                                    : currentPlatform == 2
                                        ? 'assets/images/qqmusic.png'
                                        : 'assets/images/netease.png',
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildMenuTile(
                              'Home', Icons.home_filled, _selectedIndex == 0),
                          _buildMenuTile(
                              'Profile', Icons.person, _selectedIndex == 1),
                          _buildMenuTile(
                              'Settings', Icons.settings, _selectedIndex == 2),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Log out',
                        style: textTheme.labelMedium,
                      ),
                      leading: Icon(Icons.logout),
                      onTap: () {
                        print(appState);
                        // TODO: Implement log out functionality
                      },
                      textColor: Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
