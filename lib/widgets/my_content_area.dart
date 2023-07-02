import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/retry.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/http/api.dart';
import 'package:http/http.dart' as http;
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:playlistmaster/widgets/create_playlist_popup.dart';
import 'package:playlistmaster/widgets/playlist_item.dart';
import 'package:provider/provider.dart';

class MyContentArea extends StatefulWidget {
  @override
  State<MyContentArea> createState() => _MyContentAreaState();
}

class _MyContentAreaState extends State<MyContentArea> {
  late Future<List<Playlist>?> _playlists;
  // late List<Playlist> _playlists;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      _playlists = Future.value(MockData.playlists);
    } else {
      _playlists = fetchPlaylists();
    }
  }

  Future<List<Playlist>?> fetchPlaylists() async {
    // Future<List<Playlist>> playlists;
    var url = Uri.http(
      API.host,
      '${API.playlists}/2804161589/1',
      // {'id': '2804161589'},
    );

    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        List<dynamic> jsonList = decodedResponse['data'];
        return Future.value(jsonList.map((e) => Playlist.fromJson(e)).toList());
      } else {
        // return Future.value(MockData.playlists);
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      throw Exception(e);
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _playlists,
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
                      color: Colors.black54,
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                    icon: Icon(MdiIcons.webRefresh),
                    label: Text('Retry'),
                    onPressed: () {
                      setState(() {
                        _playlists = fetchPlaylists();
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                            'Create Playlists (${(snapshot.data as List<Playlist>).length})',
                            style: TextStyle(
                              fontSize: 12.0,
                              letterSpacing: 0.25,
                              color: Color(0x59000000),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.library_add_rounded),
                            color: Color(0x42000000),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => CreatePlaylistDialog());
                            },
                          ),
                          IconButton(
                            color: Color(0x42000000),
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
                    child: (snapshot.data as List<Playlist>).isNotEmpty
                        ? ListView.builder(
                            itemCount: (snapshot.data as List<Playlist>).length,
                            itemBuilder: (context, index) {
                              return PlaylistItem(
                                playlist:
                                    (snapshot.data as List<Playlist>)[index],
                              );
                            },
                          )
                        : Center(child: Text('Empty Playlists')),
                  ),
                ],
              ),
            );
          }
        });
  }
}
