/// Lyrics of song.
class Lyrics {
  String lyric;
  String trans;

  Lyrics({
    required this.lyric,
    required this.trans,
  });
  
  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      lyric: json['lyric'],
      trans: json['trans'],
    );
  }
}
