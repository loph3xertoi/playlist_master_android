import 'package:flutter/material.dart';
import 'package:playlistmaster/widgets/song_item_in_queue.dart';
import '../entities/song.dart';

class ShowQueueDialog extends StatefulWidget {
  final List<Song> songsQueue;

  ShowQueueDialog({
    required this.songsQueue,
  });

  @override
  State<ShowQueueDialog> createState() => _ShowQueueDialogState();
}

class _ShowQueueDialogState extends State<ShowQueueDialog>
    with SingleTickerProviderStateMixin {
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
                      'Queue(${widget.songsQueue.length})',
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
                  child: (widget.songsQueue.isNotEmpty)
                      ? ListView.builder(
                          itemCount: widget.songsQueue.length,
                          itemBuilder: (context, index) {
                            var songName = widget.songsQueue[index].name;
                            var singers = widget.songsQueue[index].singers;
                            var coverUri = widget.songsQueue[index].coverUri;
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
