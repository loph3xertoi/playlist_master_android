import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/basic/basic_song.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_playlist.dart';
import 'package:playlistmaster/widgets/selectable_library_item.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../states/app_state.dart';
import 'create_library_popup.dart';

class SelectLibraryPopup extends StatefulWidget {
  const SelectLibraryPopup({
    super.key,
    required this.scrollController,
    required this.songs,
  });

  final ScrollController scrollController;
  final List<BasicSong> songs;

  @override
  State<SelectLibraryPopup> createState() => _SelectLibraryPopupState();
}

class _SelectLibraryPopupState extends State<SelectLibraryPopup> {
  late Future<List<BasicLibrary>?> _libraries;
  // Selected libraries.
  List<int> _selectedIndex = [];
  bool _inMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _libraries = state.refreshLibraries!(state, true);
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
      child: FutureBuilder(
        future: _libraries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    'Exception: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
                    ),
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all(
                        colorScheme.primary,
                      ),
                      overlayColor: MaterialStateProperty.all(
                        Colors.grey,
                      ),
                    ),
                    icon: Icon(MdiIcons.webRefresh),
                    label: Text(
                      'Retry',
                      style: textTheme.labelMedium!.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _libraries = appState.refreshLibraries!(appState, true);
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            List<BasicLibrary> libraries;
            if (currentPlatform == 1) {
              libraries = snapshot.data as List<BasicLibrary>;
            } else {
              throw Exception('Only implement for qq music platform');
            }
            return Material(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Save to library',
                          style: textTheme.labelSmall,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _inMultiSelectMode = !_inMultiSelectMode;
                            });
                            if (_selectedIndex.isNotEmpty) {
                              _addSongsToLibraries(appState, libraries);
                              Navigator.pop(context);
                            }
                          },
                          style: ButtonStyle(
                            shadowColor: MaterialStateProperty.all(
                              colorScheme.primary,
                            ),
                            overlayColor: MaterialStateProperty.all(
                              Colors.grey,
                            ),
                          ),
                          child: Text(
                            !_inMultiSelectMode
                                ? 'Multi-select'
                                : _selectedIndex.isEmpty
                                    ? 'Cancel'
                                    : 'Save(${_selectedIndex.length})',
                            style: textTheme.labelSmall,
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      controller: widget.scrollController,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              int? result = await showDialog(
                                context: context,
                                builder: (_) => CreateLibraryDialog(
                                  initText: widget.songs[0].name,
                                ),
                              );
                              // Create library successfully.
                              if (result != null && result > 0) {
                                if (appState.currentPlatform == 1) {
                                  // Temporarily library for holding dirId.
                                  BasicLibrary library = QQMusicPlaylist(
                                    result,
                                    '',
                                    name: '',
                                    cover: '',
                                    itemCount: 1,
                                  );
                                  _addSongsToLibrary(appState, library);
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  throw Exception(
                                      'Only implement qq music platform');
                                }
                              }
                            },
                            child: SelectableLibraryItem(
                              library: null,
                              isCreateLibraryItem: true,
                              inMultiSelectMode: false,
                              selected: false,
                            ),
                          ),
                        ),
                        for (int i = 0; i < libraries.length; i++)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_inMultiSelectMode) {
                                  setState(() {
                                    if (_selectedIndex.contains(i)) {
                                      _selectedIndex.remove(i);
                                    } else {
                                      _selectedIndex.add(i);
                                    }
                                  });
                                } else {
                                  _addSongsToLibrary(appState, libraries[i]);
                                  Navigator.pop(context);
                                }
                              },
                              child: SelectableLibraryItem(
                                library: libraries[i],
                                isCreateLibraryItem: false,
                                inMultiSelectMode: _inMultiSelectMode,
                                selected: _selectedIndex.contains(i),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _addSongsToLibrary(MyAppState appState, BasicLibrary library) async {
    await appState.addSongsToLibrary(
      widget.songs,
      library,
      appState.currentPlatform,
    );
    appState.refreshLibraries!(appState, true);
  }

  Future<void> _addSongsToLibraries(
      MyAppState appState, List<BasicLibrary> libraries) async {
    int platform = appState.currentPlatform;
    for (int i = 0; i < _selectedIndex.length; i++) {
      await appState.addSongsToLibrary(
        widget.songs,
        libraries[_selectedIndex[i]],
        platform,
      );
    }
    appState.refreshLibraries!(appState, true);
  }
}
