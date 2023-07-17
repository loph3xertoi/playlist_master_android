import 'package:flutter_test/flutter_test.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_playlist.dart';
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

  test('Delete library', () async {
    var map = await appState.deleteLibrary(
      QQMusicPlaylist(22, '22', name: 'name', cover: 'cover', itemCount: 1),
      1,
    );
    expect(map!['result'], equals(100));
  });
}
