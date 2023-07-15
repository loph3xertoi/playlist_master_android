import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/qq_music/qqmusic_playlist.dart';
import '../http/api.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import 'create_playlist_popup.dart';
import 'playlist_item.dart';

class MyContentArea extends StatefulWidget {
  @override
  State<MyContentArea> createState() => _MyContentAreaState();
}

class _MyContentAreaState extends State<MyContentArea> {
  late Future<List<BasicLibrary>?> _libraries;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      _libraries = Future.value(MockData.libraries);
    } else {
      _libraries = fetchLibraries(state.currentPlatform);
    }
  }

  Future<List<BasicLibrary>?> fetchLibraries(int platform) async {
    Uri url = Uri.http(API.host, API.libraries, {
      'id': API.uid,
      'platform': platform.toString(),
    });
    MyLogger.logger.d('Loading libraries from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        var jsonList = decodedResponse['data'];
        if (platform == 1) {
          return Future.value(jsonList
              .map<BasicLibrary>((e) => QQMusicPlaylist.fromJson(e))
              .toList());
        } else {
          throw Exception('Only imeplement qq music platform');
        }
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
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

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
        future: _libraries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    '${snapshot.error}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
                    ),
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all(
                        colorScheme.primary,
                      ),
                      overlayColor: MaterialStateProperty.all(
                        Colors.grey,
                      ),
                    ),
                    icon: Icon(MdiIcons.webRefresh),
                    label: Text(
                      'Retry',
                      style: textTheme.labelMedium,
                    ),
                    onPressed: () {
                      setState(() {
                        _libraries = fetchLibraries(appState.currentPlatform);
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            List<BasicLibrary> libraries = snapshot.data as List<BasicLibrary>;
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              // height: 587.0,
              child: Column(
                children: [
                  SizedBox(
                    height: 40.0,
                    child: Row(children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 13.0),
                          child: Text(
                            'Create Libraries (${libraries.length})',
                            style: textTheme.titleMedium,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.library_add_rounded),
                            color: colorScheme.tertiary,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => CreatePlaylistDialog());
                            },
                          ),
                          IconButton(
                            color: colorScheme.tertiary,
                            icon: Icon(Icons.more_vert_rounded),
                            onPressed: () {
                              // Add your search icon onPressed logic here
                            },
                          ),
                        ],
                      ),
                    ]),
                  ),
                  Expanded(
                    child: libraries.isNotEmpty
                        ? ListView.builder(
                            itemCount: libraries.length,
                            itemBuilder: (context, index) {
                              return LibraryItem(
                                library: libraries[index],
                              );
                            },
                          )
                        : Center(
                            child: Text(
                            'Empty Libraries',
                            style: textTheme.labelMedium,
                          )),
                  ),
                ],
              ),
            );
          }
        });
  }
}
