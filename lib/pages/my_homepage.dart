import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playlistmaster/http/api.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/widgets/bottom_player.dart';
import 'package:playlistmaster/widgets/floating_button/quick_action.dart';
import 'package:playlistmaster/widgets/floating_button/quick_action_menu.dart';
import 'package:playlistmaster/widgets/my_content_area.dart';
import 'package:playlistmaster/widgets/my_footer.dart';
import 'package:playlistmaster/widgets/my_searchbar.dart';
import 'package:playlistmaster/widgets/night_background.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  /// Current selected music app,
  /// 0 represents local music app, 1 represents QQ music,
  /// 2 represents netease music, 3 represents bilibili.
  var currentMusicApp = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<MyAppState>(context, listen: false).initAudioPlayer();
    // });
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        width: MediaQuery.of(context).size.width * 0.75,
        child: NightBackground(),
      ),
      body: SafeArea(
        child: QuickActionMenu(
          backgroundColor: Colors.transparent,
          imageUri: 'assets/images/home_button.png',
          onTap: () async {
            print(pow(2, 20).toInt());
            showDialog(
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Test network image',
                    textAlign: TextAlign.center,
                  ),
                  content: Image.network(MyAppState.defaultCoverImage),
                );
              },
              context: context,
            );
            print('homepage button $appState');
            // final dio = Dio();

            // final response = await dio.get('http://192.168.8.171:8080/hello');
            // print(response);

            // var url = Uri.http(
            //   '192.168.8.171:8080',
            //   '${API.playlists}/2804161589/1',
            //   // {'id': '2804161589'},
            // );
            // var response = await http.get(url);
            // var decodedResponse =
            //     jsonDecode(utf8.decode(response.bodyBytes)) as Map;
            // print(decodedResponse);
          },
          actions: [
            QuickAction(
              imageUri: 'assets/images/bilibili.png',
              onTap: () {
                print('bilibili');
              },
            ),
            QuickAction(
              imageUri: 'assets/images/netease.png',
              onTap: () {
                print('netease');
              },
            ),
            QuickAction(
              imageUri: 'assets/images/qqmusic.png',
              onTap: () {
                print('qqmusic');
              },
            ),
          ],
          child: Column(
            children: [
              MySearchBar(
                myScaffoldKey: _scaffoldKey,
                notInHomepage: false,
                inPlaylistDetailPage: false,
              ),
              // SizedBox.expand(),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF75B6F8),
                        Color(0xFFD3EAFF),
                        Color(0xFFF1F8FF),
                        Color(0xFFFFFFFF),
                        Color(0xFFFFEED9),
                      ],
                      stops: [0.0, 0.38, 0.6, 0.81, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                          child: MyContentArea(),
                        ),
                      ),
                      appState.isQueueEmpty ? Container() : BottomPlayer(),
                    ],
                  ),
                ),
              ),
              MyFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
