import 'package:flutter/material.dart';
import 'package:playlistmaster/utils/theme_manager.dart';
import 'package:provider/provider.dart';

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
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
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
                        'assets/images/qqmusic.png',
                      ),
                    ),
                    otherAccountsPictures: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/bilibili.png',
                        ),
                      ),
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/netease.png',
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
    );
  }
}
