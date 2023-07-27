import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/dto/result.dart';
import '../entities/qq_music/qqmusic_playlist.dart';
import '../states/app_state.dart';
import 'create_library_popup.dart';
import 'my_selectable_text.dart';
import 'selectable_library_item.dart';

class SelectLibraryPopup extends StatefulWidget {
  const SelectLibraryPopup({
    super.key,
    required this.scrollController,
    required this.songs,
    required this.action,
  });

  final ScrollController scrollController;
  final List<BasicSong> songs;
  final String action;

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
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MySelectableText(
                    snapshot.hasError ? '${snapshot.error}' : appState.errorMsg,
                    style: textTheme.labelMedium!.copyWith(
                      color: colorScheme.onPrimary,
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
                    icon: Icon(
                      MdiIcons.webRefresh,
                      color: colorScheme.onPrimary,
                    ),
                    label: Text(
                      'Retry',
                      style: textTheme.labelMedium!.copyWith(
                        color: colorScheme.onPrimary,
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
            if (currentPlatform == 0) {
              throw UnimplementedError('Not yet implement pms platform');
            } else if (currentPlatform == 1) {
              libraries = snapshot.data!.cast<BasicLibrary>().toList();
            } else if (currentPlatform == 2) {
              throw UnimplementedError('Not yet implement ncm platform');
            } else if (currentPlatform == 3) {
              throw UnimplementedError('Not yet implement bilibili platform');
            } else {
              throw UnsupportedError('Invalid platform');
            }
            return Material(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          widget.action == 'add'
                              ? 'Save to libraries'
                              : 'Move to libraries',
                          style: textTheme.labelSmall,
                        ),
                      ),
                      Spacer(),
                      widget.action == 'add'
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _inMultiSelectMode = !_inMultiSelectMode;
                                  });
                                  if (_selectedIndex.isNotEmpty) {
                                    _addSongsToLibraries(appState, libraries);
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
                          : Container(),
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
                              Result? result =
                                  await await showDialog<Future<Result?>>(
                                context: context,
                                builder: (_) => CreateLibraryDialog(
                                  initText: widget.songs[0].name,
                                ),
                              );

                              if (result != null && result.success) {
                                if (currentPlatform == 0) {
                                  throw UnimplementedError(
                                      'Not yet implement pms platform');
                                } else if (currentPlatform == 1) {
                                  BasicLibrary library = QQMusicPlaylist(
                                    result.data as int,
                                    '',
                                    name: '',
                                    cover: '',
                                    itemCount: 1,
                                  );
                                  widget.action == 'add'
                                      ? _addSongsToLibrary(appState, library)
                                      : _moveSongsToLibrary(appState, library);
                                } else if (currentPlatform == 2) {
                                  throw UnimplementedError(
                                      'Not yet implement ncm platform');
                                } else if (currentPlatform == 3) {
                                  throw UnimplementedError(
                                      'Not yet implement bilibili platform');
                                } else {
                                  throw UnsupportedError('Invalid platform');
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
                                  widget.action == 'add'
                                      ? _addSongsToLibrary(
                                          appState, libraries[i])
                                      : _moveSongsToLibrary(
                                          appState, libraries[i]);
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
    Future<Result?> result = appState.addSongsToLibrary(
      widget.songs,
      library,
      appState.currentPlatform,
    );
    if (mounted) {
      Navigator.pop(context, [result]);
    }
  }

  void _moveSongsToLibrary(MyAppState appState, BasicLibrary library) async {
    Future<Result?> result = appState.moveSongsToOtherLibrary(
      widget.songs,
      appState.openedLibrary!,
      library,
      appState.currentPlatform,
    );
    if (mounted) {
      Navigator.pop(context, [result]);
    }
  }

  void _addSongsToLibraries(
      MyAppState appState, List<BasicLibrary> libraries) async {
    int platform = appState.currentPlatform;
    List<Future<Result?>> results = [];
    for (int i = 0; i < _selectedIndex.length; i++) {
      results.add(appState.addSongsToLibrary(
        widget.songs,
        libraries[_selectedIndex[i]],
        platform,
      ));
    }
    appState.refreshLibraries!(appState, true);
    if (mounted) {
      Navigator.pop(context, results);
    }
  }
}
