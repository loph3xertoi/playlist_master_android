import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/dto/paged_data_dto.dart';
import '../entities/dto/result.dart';
import '../entities/netease_cloud_music/ncm_playlist.dart';
import '../entities/pms/pms_library.dart';
import '../entities/qq_music/qqmusic_playlist.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import 'create_library_popup.dart';
import 'my_selectable_text.dart';
import 'selectable_library_item.dart';

class SelectLibraryPopup extends StatefulWidget {
  const SelectLibraryPopup({
    super.key,
    required this.scrollController,
    required this.songs,
    required this.action,
    this.addToPMS = false,
  });

  final ScrollController scrollController;
  final List<BasicSong> songs;
  final String action;
  final bool addToPMS;

  @override
  State<SelectLibraryPopup> createState() => _SelectLibraryPopupState();
}

class _SelectLibraryPopupState extends State<SelectLibraryPopup> {
  late Future<PagedDataDTO<BasicLibrary>?> _libraries;

  // All libraries fetched.
  List<BasicLibrary> _localLibraries = [];

  // Selected libraries.
  List<int> _selectedIndex = [];

  bool _inMultiSelectMode = false;

  // The id of current opened library.
  late int _currentLibraryId;

  late int _currentPlatform;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _libraries = state.refreshLibraries!(state, true, widget.addToPMS);
    var currentPlatform = state.currentPlatform;
    _currentPlatform = currentPlatform;
    var rawOpenedLibrary = state.rawOpenedLibrary;
    if (currentPlatform == 0) {
      _currentLibraryId = (rawOpenedLibrary as PMSLibrary).id;
    } else if (currentPlatform == 1) {
      _currentLibraryId = (rawOpenedLibrary as QQMusicPlaylist).dirId;
    } else if (currentPlatform == 2) {
      _currentLibraryId = (rawOpenedLibrary as NCMPlaylist).id;
    } else {
      throw 'Invalid platform';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    _currentPlatform = currentPlatform;
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
            MyLogger.logger
                .e(snapshot.hasError ? '${snapshot.error}' : appState.errorMsg);
            return Material(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Got some error',
                    style: textTheme.labelLarge,
                  ),
                  backgroundColor: colorScheme.primary,
                  iconTheme: IconThemeData(color: colorScheme.onSecondary),
                ),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MySelectableText(
                        snapshot.hasError
                            ? '${snapshot.error}'
                            : appState.errorMsg,
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
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
                          color: colorScheme.onSecondary,
                        ),
                        label: Text(
                          'Retry',
                          style: textTheme.labelMedium!.copyWith(
                            color: colorScheme.onSecondary,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _libraries = appState.refreshLibraries!(
                                appState, true, widget.addToPMS);
                            _localLibraries.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            PagedDataDTO<BasicLibrary>? pagedDataDTO = snapshot.data!;
            var totalCount = pagedDataDTO.count;
            if (totalCount != 0 && _localLibraries.isEmpty) {
              List<BasicLibrary>? libraries = pagedDataDTO.list;
              _localLibraries.addAll(libraries!);
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
                              ? widget.addToPMS
                                  ? 'Save to pms'
                                  : 'Save to libraries'
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
                                    _addSongsToLibraries(appState,
                                        _localLibraries, widget.addToPMS);
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
                    child: RefreshIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2.0,
                      onRefresh: () async {
                        setState(() {
                          _libraries = appState.refreshLibraries!(
                              appState, true, widget.addToPMS);
                          _localLibraries.clear();
                        });
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                    addToPMS: widget.addToPMS,
                                  ),
                                );

                                if (result != null && result.success) {
                                  if (widget.addToPMS || currentPlatform == 0) {
                                    BasicLibrary library = PMSLibrary(
                                      result.data as int,
                                      1,
                                      name: '',
                                      cover: '',
                                      itemCount: 1,
                                    );
                                    if (widget.addToPMS ||
                                        widget.action == 'add') {
                                      _addSongsToLibrary(
                                          appState, library, widget.addToPMS);
                                    } else {
                                      _moveSongsToLibrary(appState, library);
                                    }
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
                                        : _moveSongsToLibrary(
                                            appState, library);
                                  } else if (currentPlatform == 2) {
                                    BasicLibrary library = NCMPlaylist(
                                      result.data as int,
                                      name: '',
                                      cover: '',
                                      itemCount: 1,
                                    );
                                    widget.action == 'add'
                                        ? _addSongsToLibrary(appState, library)
                                        : _moveSongsToLibrary(
                                            appState, library);
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
                          for (int i = 0; i < _localLibraries.length; i++)
                            if (_currentLibraryId !=
                                _getIdentifiedIdOfLibrary(_localLibraries[i]))
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
                                              appState,
                                              _localLibraries[i],
                                              widget.addToPMS)
                                          : _moveSongsToLibrary(
                                              appState, _localLibraries[i]);
                                    }
                                  },
                                  child: SelectableLibraryItem(
                                    library: _localLibraries[i],
                                    isCreateLibraryItem: false,
                                    inMultiSelectMode: _inMultiSelectMode,
                                    selected: _selectedIndex.contains(i),
                                  ),
                                ),
                              ),
                        ],
                      ),
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

  void _addSongsToLibrary(MyAppState appState, BasicLibrary library,
      [bool addToPMS = false]) async {
    Future<Result?> result = appState.addSongsToLibrary(
      widget.songs,
      library,
      addToPMS,
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

  void _addSongsToLibraries(MyAppState appState, List<BasicLibrary> libraries,
      [bool addToPMS = false]) async {
    int platform = appState.currentPlatform;
    List<Future<Result?>> results = [];
    for (int i = 0; i < _selectedIndex.length; i++) {
      BasicLibrary library = libraries[_selectedIndex[i]];
      results.add(appState.addSongsToLibrary(
        widget.songs,
        library,
        addToPMS,
        platform,
      ));
    }
    appState.refreshLibraries!(appState, true, addToPMS);
    if (mounted) {
      Navigator.pop(context, results);
    }
  }

  int _getIdentifiedIdOfLibrary(BasicLibrary library) {
    if (_currentPlatform == 0 || widget.addToPMS) {
      return (library as PMSLibrary).id;
    } else if (_currentPlatform == 1) {
      return (library as QQMusicPlaylist).dirId;
    } else if (_currentPlatform == 2) {
      return (library as NCMPlaylist).id;
    } else {
      throw 'Invalid platform';
    }
  }
}
