import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/widgets/create_confirm_popup.dart';
import 'package:playlistmaster/widgets/song_item_in_queue.dart';
import 'package:provider/provider.dart';

class ShowQueueDialog extends StatefulWidget {
  @override
  State<ShowQueueDialog> createState() => _ShowQueueDialogState();
}

class _ShowQueueDialogState extends State<ShowQueueDialog>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    List<Song>? queue = appState.queue;
    int? queueLength = queue?.length ?? 0;
    int currentPlaying = appState.currentPlayingSongInQueue;
    if (appState.queue!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
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
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25.0, 0.0, 12.0, 0.0),
                child: Row(children: [
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShowConfirmDialog(),
                      );
                    },
                  )
                ]),
              ),
              Expanded(
                child: (appState.isQueueEmpty)
                    ? Center(child: Text('Empty Queue'))
                    : ListView.builder(
                        itemCount: queueLength,
                        itemBuilder: (context, index) {
                          var songName = queue![index].name;
                          var singers = queue[index].singers;
                          var coverUri = queue[index].coverUri;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (appState.currentPlayingSongInQueue ==
                                    index) {
                                  return;
                                }
                                appState.currentPlayingSongInQueue = index;
                                appState.isPlaying = true;
                              },
                              child: Container(
                                margin:
                                    EdgeInsets.fromLTRB(25.0, 0.0, 12.0, 0.0),
                                child: SongItemInQueue(
                                  name: songName,
                                  coverUri: coverUri,
                                  singers: singers,
                                  isPlaying:
                                      (currentPlaying == index) ? true : false,
                                  onClose: () {
                                    if (index < currentPlaying) {
                                      currentPlaying--;
                                    } else if (index > currentPlaying) {
                                    } else if (currentPlaying ==
                                        queueLength - 1) {
                                      currentPlaying = 0;
                                    }
                                    appState.queue!.removeAt(index);
                                    appState.currentPlayingSongInQueue =
                                        currentPlaying;
                                    // setState(() {});
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
