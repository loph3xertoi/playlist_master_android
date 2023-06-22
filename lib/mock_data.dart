import 'entities/playlist.dart';
import 'entities/singer.dart';
import 'entities/song.dart';

class MockData {
  static List<Singer> singers = [
    Singer(
      id: '1',
      mid: '1',
      name: 'Giant Parakeet',
    ),
    Singer(
      id: '2',
      mid: '2',
      name: 'Little Chickadee',
    ),
    Singer(
      id: '3',
      mid: '3',
      name: 'Mysterious Owlet',
    ),
    Singer(
      id: '4',
      mid: '4',
      name: 'Lovely Budgerigar',
    ),
    Singer(
      id: '5',
      mid: '5',
      name: 'Funny Blue Jay',
    ),
    Singer(
      id: '6',
      mid: '6',
      name: 'Smart Columbidae',
    ),
    Singer(
      id: '7',
      mid: '7',
      name: 'Beautiful Hummingbirds',
    ),
    Singer(
      id: '8',
      mid: '8',
      name: 'Intelligent Toucans',
    ),
    Singer(
      id: '9',
      mid: '9',
      name: 'Adorable Finches',
    ),
    Singer(
      id: '10',
      mid: '10',
      name: 'Vibrant Bluebirds',
    ),
  ];

  static List<Song> songs = [
    Song(
      name: 'Parrot',
      singers: [singers[0]],
      coverUri: 'assets/images/songs_cover/parrot.jpeg',
      link: 'assets/audios/parrot.mp3',
    ),
    Song(
      name: 'Tit',
      singers: [singers[1]],
      coverUri: 'assets/images/songs_cover/tit.jpeg',
      link: 'assets/audios/tit.mp3',
    ),
    Song(
      name: 'Owl',
      singers: [singers[2]],
      coverUri: 'assets/images/songs_cover/owl.jpeg',
      link: 'assets/audios/owl.mp3',
    ),
    Song(
      name: 'Budgerigar',
      singers: [singers[3]],
      coverUri: 'assets/images/songs_cover/budgerigar.jpeg',
      link: 'assets/audios/budgerigar.mp3',
    ),
    Song(
      name: 'Blue Jay',
      singers: [singers[4]],
      coverUri: 'assets/images/songs_cover/bluejay.jpeg',
      link: 'assets/audios/bluejay.mp3',
    ),
    Song(
      name: 'Columbidae',
      singers: [singers[5]],
      coverUri: 'assets/images/songs_cover/columbidae.jpeg',
      link: 'assets/audios/columbidae.mp3',
    ),
    Song(
      name: 'Hummingbirds',
      singers: [singers[6]],
      coverUri: 'assets/images/songs_cover/hummingbirds.jpeg',
      link: 'assets/audios/hummingbirds.mp3',
    ),
    Song(
      name: 'Toucans',
      singers: [singers[7]],
      coverUri: 'assets/images/songs_cover/toucans.jpeg',
      link: 'assets/audios/toucans.mp3',
    ),
    Song(
      name: 'Finches',
      singers: [singers[8]],
      coverUri: 'assets/images/songs_cover/finches.jpeg',
      link: 'assets/audios/finches.mp3',
    ),
    Song(
      name: 'Bluebirds',
      singers: [singers[9]],
      coverUri: 'assets/images/songs_cover/bluebirds.jpeg',
      link: 'assets/audios/bluebirds.mp3',
    ),
  ];

  static List<Playlist> playlists = [
    Playlist(
      name: 'Bird',
      coverImage: 'assets/images/playlist_cover/bird.png',
      description:
          'A bird does not sing because it has an answer, it sings because it has a song.',
      songsCount: 20,
      listenNum: 10,
      dirId: 1,
      tid: '1',
    ),
    Playlist(
      name: 'Zebra',
      coverImage: 'assets/images/playlist_cover/zebra.png',
      songsCount: 24,
      listenNum: 10,
      dirId: 2,
      tid: '2',
    ),
    Playlist(
      name: 'Cat',
      coverImage: 'assets/images/playlist_cover/cat.png',
      songsCount: 3,
      listenNum: 10,
      dirId: 3,
      tid: '3',
    ),
    Playlist(
      name: 'Owl',
      coverImage: 'assets/images/playlist_cover/owl.png',
      songsCount: 68,
      listenNum: 10,
      dirId: 4,
      tid: '4',
    ),
    Playlist(
      name: 'Shark',
      coverImage: 'assets/images/playlist_cover/shark.png',
      songsCount: 23,
      listenNum: 10,
      dirId: 5,
      tid: '5',
    ),
    Playlist(
      name: 'Panther',
      coverImage: 'assets/images/playlist_cover/panther.png',
      songsCount: 30,
      listenNum: 10,
      dirId: 6,
      tid: '6',
    ),
    Playlist(
      name: 'Lion',
      coverImage: 'assets/images/playlist_cover/lion.png',
      songsCount: 89,
      listenNum: 10,
      dirId: 7,
      tid: '7',
    ),
    Playlist(
      name: 'Fox',
      coverImage: 'assets/images/playlist_cover/fox.png',
      songsCount: 169,
      listenNum: 10,
      dirId: 8,
      tid: '8',
    ),
    Playlist(
      name: 'Dog',
      coverImage: 'assets/images/playlist_cover/dog.png',
      songsCount: 72,
      listenNum: 10,
      dirId: 9,
      tid: '9',
    ),
    Playlist(
      name: 'Dolphin',
      coverImage: 'assets/images/playlist_cover/dolphin.png',
      songsCount: 83,
      listenNum: 10,
      dirId: 10,
      tid: '10',
    ),
    Playlist(
      name: 'Rabbit',
      coverImage: 'assets/images/playlist_cover/rabbit.png',
      songsCount: 24,
      listenNum: 10,
      dirId: 11,
      tid: '11',
    ),
    Playlist(
      name: 'Elephant',
      coverImage: 'assets/images/playlist_cover/elephant.png',
      songsCount: 75,
      listenNum: 10,
      dirId: 12,
      tid: '12',
    ),
    Playlist(
      name: 'Wolf',
      coverImage: 'assets/images/playlist_cover/wolf.png',
      songsCount: 98,
      listenNum: 10,
      dirId: 13,
      tid: '13',
    ),
    Playlist(
      name: 'Dove',
      coverImage: 'assets/images/playlist_cover/dove.png',
      songsCount: 56,
      listenNum: 10,
      dirId: 14,
      tid: '14',
    ),
    Playlist(
      name: 'Snake',
      coverImage: 'assets/images/playlist_cover/snake.png',
      songsCount: 65,
      listenNum: 10,
      dirId: 15,
      tid: '15',
    ),
    Playlist(
      name: 'Bear',
      coverImage: 'assets/images/playlist_cover/bear.png',
      songsCount: 32,
      listenNum: 10,
      dirId: 16,
      tid: '16',
    ),
    Playlist(
      name: 'Bee',
      coverImage: 'assets/images/playlist_cover/bee.png',
      songsCount: 58,
      listenNum: 10,
      dirId: 17,
      tid: '17',
    ),
    Playlist(
      name: 'Panda',
      coverImage: 'assets/images/playlist_cover/panda.png',
      songsCount: 80,
      listenNum: 10,
      dirId: 18,
      tid: '18',
    ),
    Playlist(
      name: 'Koala',
      coverImage: 'assets/images/playlist_cover/koala.png',
      songsCount: 7,
      listenNum: 10,
      dirId: 19,
      tid: '19',
    ),
    Playlist(
      name: 'Lizard',
      coverImage: 'assets/images/playlist_cover/lizard.png',
      songsCount: 73,
      listenNum: 10,
      dirId: 20,
      tid: '20',
    ),
  ];
}
