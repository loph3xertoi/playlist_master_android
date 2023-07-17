import 'package:flutter_test/flutter_test.dart';
import 'package:playlistmaster/states/app_state.dart';

void main() {
  MyAppState appState = MyAppState();
  test('Test fetch user', () async {
    print(await appState.fetchUser(1));
  });

  // test('Test fetch detail song', () async {
  //   print(await appState.fetchDetailSong(song, platform));
  // });
}
