import 'package:playlistmaster/entities/singer.dart';

class Song {
  String name;
  List<Singer> singers;
  String coverUri;
  
  Song({
    required this.name,
    required this.singers,
    required this.coverUri,
  });
}
