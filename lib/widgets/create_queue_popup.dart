import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/widgets/song_item_in_queue.dart';
import 'package:provider/provider.dart';

class ShowQueueDialog extends StatefulWidget {
  @override
  State<ShowQueueDialog> createState() => _ShowQueueDialogState();
}

class _ShowQueueDialogState extends State<ShowQueueDialog>
    with SingleTickerProviderStateMixin {
  int _currentPlaying = 1;

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    List<Song>? queue = appState.queue;
    int? queueLength = queue?.length ?? 0;
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
                      'Queue($queueLength)',
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
                  child: (appState.isQueueEmpty)
                      ? Center(child: Text('Empty Queue'))
                      : ListView.builder(
                          itemCount: queueLength,
                          itemBuilder: (context, index) {
                            var songName = queue![index].name;
                            var singers = queue[index].singers;
                            var coverUri = queue[index].coverUri;
                            return SongItemInQueue(
                              name: songName,
                              coverUri: coverUri,
                              singers: singers,
                              isPlaying:
                                  (_currentPlaying == index) ? true : false,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
