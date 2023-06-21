import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repeat Playlist',
      home: RepeatPlaylist(),
    );
  }
}

class RepeatPlaylist extends StatefulWidget {
  @override
  State<RepeatPlaylist> createState() => _RepeatPlaylistState();
}

class _RepeatPlaylistState extends State<RepeatPlaylist> {
  List<Map<String, dynamic>> _songs = [
    {
      'title': 'Parrot',
      'cover': 'assets/images/songs_cover/parrot.png',
    },
    {
      'title': 'Tit',
      'cover': 'assets/images/songs_cover/tit.png',
    },
    {
      'title': 'Owl',
      'cover': 'assets/images/songs_cover/owl.png',
    },
  ];
  int _currentSongIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repeat Playlist'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: -120,
              child: Image.asset(
                _songs[(_currentSongIndex - 1) % _songs.length]['cover'],
                width: 240,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: -120,
              child: Image.asset(
                _songs[(_currentSongIndex + 1) % _songs.length]['cover'],
                width: 240,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
            Image.asset(
              _songs[_currentSongIndex]['cover'],
              width: 240,
              height: 240,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
