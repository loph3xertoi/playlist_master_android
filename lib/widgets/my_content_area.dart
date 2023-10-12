import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/dto/paged_data_dto.dart';
import '../entities/dto/result.dart';
import '../http/my_http.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import 'create_library_popup.dart';
import 'libraries_settings_menu_popup.dart';
import 'library_item.dart';
import 'my_selectable_text.dart';

class MyContentArea extends StatefulWidget {
  @override
  State<MyContentArea> createState() => _MyContentAreaState();
}

class _MyContentAreaState extends State<MyContentArea> {
  late Future<PagedDataDTO<BasicLibrary>?> _futurePagedLibraries;

  // Current page number, only for bilibili.
  int _currentPage = 1;

  // All libraries fetched, in local storage.
  List<BasicLibrary>? _localLibraries = [];

  bool _isLoading = false;

  // Whether has more libraries.
  bool _hasMore = true;

  MyAppState? _appState;

  ScrollController _scrollController = ScrollController();

  Future<PagedDataDTO<BasicLibrary>?> _refreshLibraries(
      MyAppState appState, bool delayRebuild,
      [bool addToPMS = false]) async {
    _currentPage = 1;
    _hasMore = true;
    var currentPlatform = addToPMS ? 0 : appState.currentPlatform;
    if (appState.isUsingMockData) {
      var pagedDataDTO = PagedDataDTO<BasicLibrary>(
          MockData.libraries.length, MockData.libraries, false);
      _futurePagedLibraries = Future.value(pagedDataDTO);
    } else {
      _futurePagedLibraries =
          appState.fetchLibraries(currentPlatform, _currentPage.toString());
    }
    _localLibraries?.clear();
    if (delayRebuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    } else {
      setState(() {});
    }
    return _futurePagedLibraries;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore) {
        _fetchingLibraries(_appState!);
      } else {
        MyToast.showToast('No more libraries');
      }
    }
  }

  // Future<void> _fetchingLibraries() async {
  //   int platform = _state.currentPlatform;
  //   if (!_isLoading && _hasMore) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     _currentPage++;
  //     Future<PagedDataDTO<BasicLibrary>?> pagedData =
  //         _state.fetchLibraries(platform, _currentPage.toString());
  //     setState(() {
  //       _futurePagedLibraries = pagedData;
  //       _isLoading = false;
  //     });
  //   } else {
  //     MyToast.showToast('No more data');
  //   }
  // }

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
            _localLibraries!.addAll(pageLibraries!);
          }
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      var pagedDataDTO = PagedDataDTO<BasicLibrary>(
          MockData.libraries.length, MockData.libraries, false);
      _futurePagedLibraries = Future.value(pagedDataDTO);
    } else {
      _futurePagedLibraries = state.fetchLibraries(state.currentPlatform, '1');
    }
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.refreshLibraries = _refreshLibraries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
    return FutureBuilder(
        future: _futurePagedLibraries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            MyLogger.logger
                .e(snapshot.hasError ? '${snapshot.error}' : appState.errorMsg);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MySelectableText(
                    snapshot.hasError ? '${snapshot.error}' : appState.errorMsg,
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
                        _futurePagedLibraries =
                            _refreshLibraries(appState, false);
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            PagedDataDTO<BasicLibrary>? pagedDataDTO = snapshot.data!;
            var totalCount = pagedDataDTO.count;
            // Only add libraries of this snapshot.data in the first page,
            // add other libraries to _localLibraries inside _fetchingLibraries.
            // To avoid stuck, don't rebuild the widget when fetching new libraries.
            if (totalCount != 0 &&
                _currentPage == 1 &&
                _localLibraries!.isEmpty) {
              List<BasicLibrary>? libraries = pagedDataDTO.list;
              _hasMore = pagedDataDTO.hasMore;
              _localLibraries?.addAll(libraries!);
            }
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              // height: 587.0,
              child: Column(
                children: [
                  SizedBox(
                    height: 40.0,
                    child: Row(children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 13.0),
                          child: Text(
                            'Create Libraries ($totalCount)',
                            style: textTheme.titleMedium,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.library_add_rounded),
                            color: colorScheme.tertiary,
                            tooltip: 'Create library',
                            onPressed: () async {
                              Result? result =
                                  await await showDialog<Future<Result?>>(
                                context: context,
                                builder: (_) => CreateLibraryDialog(),
                              );
                              if (result != null && result.success) {
                                appState.refreshLibraries!(appState, false);
                              }
                            },
                          ),
                          IconButton(
                            color: colorScheme.tertiary,
                            icon: Icon(Icons.more_vert_rounded),
                            tooltip: 'Library settings',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => LibrariesSettingsPopup(),
                              );
                            },
                          ),
                        ],
                      ),
                    ]),
                  ),
                  Expanded(
                    child: _localLibraries!.isNotEmpty
                        ? RefreshIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2.0,
                            onRefresh: () async {
                              await MyHttp.clearCache();
                              setState(() {
                                _currentPage = 1;
                                _futurePagedLibraries =
                                    _refreshLibraries(appState, false);
                              });
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              itemCount: _localLibraries!.length + 1,
                              itemBuilder: (context, index) {
                                if (index < _localLibraries!.length) {
                                  return Material(
                                    color: Colors.transparent,
                                    child: LibraryItem(
                                      library: _localLibraries![index],
                                    ),
                                  );
                                } else {
                                  return _buildLoadingIndicator(colorScheme);
                                }
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                            'Empty Libraries',
                            style: textTheme.labelMedium,
                          )),
                  ),
                ],
              ),
            );
          }
        });
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
}
