import 'package:playlistmaster/entities/singer.dart';

class BasicSong {
  String songName;
  String songId;
  String songMid;
  String mediaMid;
  List<Singer> singers;
  int payPlay;

  BasicSong({
    required this.songName,
    required this.songId,
    required this.songMid,
    required this.mediaMid,
    required this.singers,
    required this.payPlay,
  });
}
