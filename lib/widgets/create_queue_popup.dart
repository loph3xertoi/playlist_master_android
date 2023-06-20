import 'package:flutter/material.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/widgets/song_item_in_queue.dart';
import '../entities/song.dart';

class ShowQueueDialog extends StatefulWidget {
  @override
  State<ShowQueueDialog> createState() => _ShowQueueDialogState();
}

class _ShowQueueDialogState extends State<ShowQueueDialog>
    with SingleTickerProviderStateMixin {
  List<Song> _songsQueue = MockData.songs;
  int _currentPlaying = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      child: Material(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: SizedBox(
          height: 480,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(25.0, 0.0, 12.0, 0.0),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      'Queue(${_songsQueue.length})',
                      style: TextStyle(
                        color: Color(0x42000000),
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded),
                    color: Color(0x42000000),
                    onPressed: () {},
                  )
                ]),
                Expanded(
                  child: (_songsQueue.isNotEmpty)
                      ? ListView.builder(
                          itemCount: _songsQueue.length,
                          itemBuilder: (context, index) {
                            var songName = _songsQueue[index].name;
                            var singers = _songsQueue[index].singers;
                            var coverUri = _songsQueue[index].coverUri;
                            return SongItemInQueue(
                              name: songName,
                              coverUri: coverUri,
                              singers: singers,
                              isPlaying:
                                  (_currentPlaying == index) ? true : false,
                            );
                          },
                        )
                      : Center(child: Text('Empty Queue')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
