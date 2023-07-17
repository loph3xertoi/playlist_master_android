import 'package:flutter_test/flutter_test.dart';
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
    var map = await appState.deleteLibrary(22, 1);
    expect(map!['result'], equals(100));
  });
}
