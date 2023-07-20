import 'package:flutter_test/flutter_test.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_playlist.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_song.dart';
import 'package:playlistmaster/states/app_state.dart';

void main() {
  MyAppState appState = MyAppState();
  test('Fetch user', () async {
    print(await appState.fetchUser(1));
  });

  test('Create library', () async {
    var map = await appState.createLibrary('daw\'s library', 1);
    expect(map!['result'], equals(100));
  });

  test('Delete libraries', () async {
    var map = await appState.deleteLibraries(
      [
        QQMusicPlaylist(22, '22', name: 'name1', cover: 'cover1', itemCount: 1),
        QQMusicPlaylist(23, '23', name: 'name2', cover: 'cover2', itemCount: 1),
      ],
      1,
    );
    expect(map!['result'], equals(100));
  });

  test('Add songs to library', () async {
    var map = await appState.addSongsToLibrary(
      [
        QQMusicSong(
          '414119681',
          '003nkjOy4dtZxc',
          '003nkjOy4dtZxc',
          name: '云与诗',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        ),
        QQMusicSong(
          '105302677',
          '000idahy2pT761',
          '001FuBpI3XLu09',
          name: '狐言',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        ),
        QQMusicSong(
          '414478884',
          '001OgIGc0B4OEL',
          '001OgIGc0B4OEL',
          name: '未来之礼',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        )
      ],
      QQMusicPlaylist(22, '1', name: 'daw', cover: 'cover', itemCount: 1),
      1,
    );
    expect(map!['result'], equals(100));
  });
  // songId: 414119681,105302677,414478884
  // songMid: 003nkjOy4dtZxc,000idahy2pT761,001OgIGc0B4OEL
  test('Remove songs from library', () async {
    var map = await appState.removeSongsFromLibrary(
      [
        QQMusicSong(
          '414119681',
          '003nkjOy4dtZxc',
          '003nkjOy4dtZxc',
          name: '云与诗',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        ),
        QQMusicSong(
          '105302677',
          '000idahy2pT761',
          '001FuBpI3XLu09',
          name: '狐言',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        ),
        QQMusicSong(
          '414478884',
          '001OgIGc0B4OEL',
          '001OgIGc0B4OEL',
          name: '未来之礼',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        )
      ],
      QQMusicPlaylist(22, '1', name: 'daw', cover: 'cover', itemCount: 1),
      1,
    );
    expect(map!['result'], equals(100));
  });

  test('Move songs from one library to another library', () async {
    var map = await appState.moveSongsToOtherLibrary(
      [
        QQMusicSong(
          '414119681',
          '003nkjOy4dtZxc',
          '003nkjOy4dtZxc',
          name: '云与诗',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        ),
        QQMusicSong(
          '105302677',
          '000idahy2pT761',
          '001FuBpI3XLu09',
          name: '狐言',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        ),
        QQMusicSong(
          '414478884',
          '001OgIGc0B4OEL',
          '001OgIGc0B4OEL',
          name: '未来之礼',
          singers: [],
          cover: '',
          payPlay: 0,
          isTakenDown: false,
          songLink: '',
        )
      ],
      QQMusicPlaylist(25, '1', name: 'daw', cover: 'cover', itemCount: 1),
      QQMusicPlaylist(22, '1', name: 'daw', cover: 'cover', itemCount: 1),
      1,
    );
    expect(map!['result'], equals(100));
  });
}
