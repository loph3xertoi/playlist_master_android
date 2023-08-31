import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/bilibili/bili_fav_list.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/dto/paged_data_dto.dart';
import '../entities/dto/result.dart';
import '../entities/netease_cloud_music/ncm_playlist.dart';
import '../entities/pms/pms_library.dart';
import '../entities/qq_music/qqmusic_playlist.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import 'create_library_popup.dart';
import 'my_selectable_text.dart';
import 'selectable_library_item.dart';

class SelectFavListPopup extends StatefulWidget {
  const SelectFavListPopup({
    super.key,
    required this.scrollController,
    required this.biliSourceFavListId,
    required this.resources,
    required this.action,
    this.addToPMS = false,
  });

  final int biliSourceFavListId;
  final List<BiliResource> resources;
  final String action;
  final bool addToPMS;
  final ScrollController scrollController;

  @override
  State<SelectFavListPopup> createState() => _SelectFavListPopupState();
}

class _SelectFavListPopupState extends State<SelectFavListPopup> {
  late Future<PagedDataDTO<BasicLibrary>?> _favlists;

  // Current page number, only for bilibili.
  int _currentPage = 1;

  // All favlists fetched.
  List<BasicLibrary> _localFavLists = [];

  bool _isLoading = false;

  // Whether has more favlist.
  bool _hasMore = true;

  // Selected favlists.
  List<int> _selectedIndex = [];

  bool _inMultiSelectMode = false;

  MyAppState? _appState;

  late int _currentPlatform;

  // The id of current opened library.
  late int _currentFavlistId;

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _favlists = state.refreshLibraries!(state, true, widget.addToPMS);
    _currentPlatform = state.currentPlatform;
    widget.scrollController.addListener(_scrollListener);
    var rawOpenedLibrary = state.rawOpenedLibrary;
    if (_currentPlatform == 3) {
      _currentFavlistId = (rawOpenedLibrary as BiliFavList).id;
    } else {
      throw 'Invalid platform';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
      child: FutureBuilder(
        future: _favlists,
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
                            _currentPage = 1;
                            _favlists =
                                appState.refreshLibraries!(appState, true);
                            _localFavLists.clear();
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
            if (totalCount != 0 &&
                _currentPage == 1 &&
                _localFavLists.isEmpty) {
              List<BasicLibrary>? libraries = pagedDataDTO.list;
              _hasMore = pagedDataDTO.hasMore;
              _localFavLists.addAll(libraries!);
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
                                    _addResourcesToFavLists(
                                        _localFavLists, appState);
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
                      color: Color(0xFFFB6A9D),
                      strokeWidth: 2.0,
                      onRefresh: () async {
                        setState(() {
                          _favlists =
                              appState.refreshLibraries!(appState, true);
                          _localFavLists.clear();
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
                                    initText: widget.resources[0].title,
                                  ),
                                );

                                if (result != null && result.success) {
                                  if (_currentPlatform == 0) {
                                    throw UnimplementedError(
                                        'Not yet implement pms _currentPlatform');
                                  } else if (_currentPlatform == 1) {
                                    BasicLibrary library = QQMusicPlaylist(
                                      result.data as int,
                                      '',
                                      name: '',
                                      cover: '',
                                      itemCount: 1,
                                    );
                                    if (widget.addToPMS ||
                                        widget.action == 'add') {
                                      _addResourcesToFavList(
                                          appState, library, widget.addToPMS);
                                    } else {
                                      _moveResourcesToFavList(
                                          appState, library);
                                    }
                                  } else if (_currentPlatform == 2) {
                                    BasicLibrary library = NCMPlaylist(
                                      result.data as int,
                                      name: '',
                                      cover: '',
                                      itemCount: 1,
                                    );
                                    widget.action == 'add'
                                        ? _addResourcesToFavList(
                                            appState, library)
                                        : _moveResourcesToFavList(
                                            appState, library);
                                  } else if (_currentPlatform == 3) {
                                    BiliFavList favList = BiliFavList(
                                        result.data as int, 0, 0, '', 0, 0,
                                        name: '', cover: '', itemCount: 1);
                                    widget.action == 'add'
                                        ? _addResourcesToFavList(
                                            appState, favList)
                                        : _moveResourcesToFavList(
                                            appState, favList);
                                  } else {
                                    throw UnsupportedError(
                                        'Invalid _currentPlatform');
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
                          for (int i = 0; i < _localFavLists.length; i++)
                            if (_currentFavlistId !=
                                _getIdentifiedIdOfFavList(_localFavLists[i]))
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
                                          ? _addResourcesToFavList(
                                              appState,
                                              _localFavLists[i],
                                              widget.addToPMS)
                                          : _moveResourcesToFavList(
                                              appState, _localFavLists[i]);
                                    }
                                  },
                                  child: SelectableLibraryItem(
                                    library: _localFavLists[i],
                                    isCreateLibraryItem: false,
                                    inMultiSelectMode: _inMultiSelectMode,
                                    selected: _selectedIndex.contains(i),
                                  ),
                                ),
                              ),
                          _buildLoadingIndicator(colorScheme),
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

  void _scrollListener() {
    if (widget.scrollController.position.pixels ==
        widget.scrollController.position.maxScrollExtent) {
      if (_hasMore) {
        _fetchingLibraries(_appState!);
      } else {
        MyToast.showToast('No more favlists');
      }
    }
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                  height: 10.0,
                  width: 10.0,
                  child: CircularProgressIndicator(
                    color: colorScheme.onPrimary,
                    strokeWidth: 2.0,
                  )),
            ),
          )
        : Container();
  }

  void _addResourcesToFavList(MyAppState appState, BasicLibrary favList,
      [bool addToPMS = false]) async {
    Future<Result?> result;
    String favListIds;
    if (!addToPMS) {
      favListIds = (favList as BiliFavList).id.toString();
    } else {
      favListIds = (favList as PMSLibrary).id.toString();
    }
    if (widget.biliSourceFavListId == 0) {
      result = appState.addResourcesToFavList(
        widget.resources,
        widget.biliSourceFavListId,
        true,
        addToPMS,
        favListIds,
        _currentPlatform,
      );
    } else {
      result = appState.addResourcesToFavList(
        widget.resources,
        widget.biliSourceFavListId,
        false,
        addToPMS,
        favListIds,
        _currentPlatform,
      );
    }

    if (mounted) {
      Navigator.pop(context, [result]);
    }
  }

  void _moveResourcesToFavList(
      MyAppState appState, BasicLibrary favList) async {
    Future<Result?> result = appState.moveResourcesToOtherFavList(
      widget.resources,
      appState.openedLibrary!,
      favList,
      _currentPlatform,
    );
    if (mounted) {
      Navigator.pop(context, [result]);
    }
  }

  Future<void> _fetchingLibraries(MyAppState appState) async {
    int platform = appState.currentPlatform;
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      _currentPage++;
      List<BasicLibrary>? pageLibraries;
      PagedDataDTO<BasicLibrary>? pagedData =
          await appState.fetchLibraries(platform, _currentPage.toString());
      setState(() {
        if (pagedData != null) {
          _hasMore = pagedData.hasMore;
          pageLibraries = pagedData.list;
          if (pageLibraries != null && pageLibraries!.isNotEmpty) {
            _localFavLists.addAll(pageLibraries!);
          }
        }
        _isLoading = false;
      });
    }
  }

  void _addResourcesToFavLists(
      List<BasicLibrary> favLists, MyAppState appState) async {
    List<Future<Result?>> results = [];
    // Favorite resources to fav list.
    if (widget.biliSourceFavListId == 0) {
      String favListsIds = _selectedIndex
          .map((e) => (favLists[e] as BiliFavList).id)
          .toList()
          .join(',');
      results.add(appState.addResourcesToFavList(
        widget.resources,
        widget.biliSourceFavListId,
        true,
        false,
        favListsIds,
        _currentPlatform,
      ));
    } else {
      for (int i = 0; i < _selectedIndex.length; i++) {
        results.add(appState.addResourcesToFavList(
          widget.resources,
          widget.biliSourceFavListId,
          false,
          false,
          (favLists[_selectedIndex[i]] as BiliFavList).id.toString(),
          _currentPlatform,
        ));
      }
    }
    // appState.refreshLibraries!(appState, true);
    if (mounted) {
      Navigator.pop(context, results);
    }
  }

  int _getIdentifiedIdOfFavList(BasicLibrary library) {
    if (widget.addToPMS) {
      return (library as PMSLibrary).id;
    } else if (_currentPlatform == 3) {
      return (library as BiliFavList).id;
    } else {
      throw 'Invalid platform';
    }
  }
}
