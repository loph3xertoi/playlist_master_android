/// Singer of song.
class Singer {
  String id;
  String mid;
  String name;

  Singer({
    required this.id,
    required this.mid,
    required this.name,
  });
  
  factory Singer.fromJson(Map<String, dynamic> json) {
    return Singer(
      id: json['id'],
      mid: json['mid'],
      name: json['name'],
    );
  }
}
