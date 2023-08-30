import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/dto/paged_data_dto.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import 'confirm_popup.dart';
import 'my_selectable_text.dart';
import 'selectable_library_item.dart';

class MultiLibrariesSelectPopup extends StatefulWidget {
  @override
  State<MultiLibrariesSelectPopup> createState() =>
      _MultiLibrariesSelectPopupState();
}

class _MultiLibrariesSelectPopupState extends State<MultiLibrariesSelectPopup> {
  List<int> _selectedIndex = [];

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
    _appState = state;
    var isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      var pagedDataDTO = PagedDataDTO<BasicLibrary>(
          MockData.libraries.length, MockData.libraries, false);
      _futurePagedLibraries = Future.value(pagedDataDTO);
    } else {
      _futurePagedLibraries = state.fetchLibraries(state.currentPlatform, '1');
    }
    _scrollController.addListener(_scrollListener);
  }

  void _removeSelectedLibraries(MyAppState appState) async {
    List<BasicLibrary> removedLibraries =
        _selectedIndex.map((index) => _localLibraries![index]).toList();
    setState(() {
      _selectedIndex.clear();
    });
    await appState.deleteLibraries(removedLibraries, appState.currentPlatform);
    appState.refreshLibraries!(appState, false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
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
                            _futurePagedLibraries =
                                appState.refreshLibraries!(appState, false);
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
            return Dialog(
              insetPadding: EdgeInsets.all(0.0),
              alignment: Alignment.bottomCenter,
              child: Material(
                color: colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppBar(
                      leading: IconButton(
                        color: colorScheme.tertiary,
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      centerTitle: true,
                      title: Text(
                        _selectedIndex.isEmpty
                            ? 'Delete libraries'
                            : '${_selectedIndex.length} libraries selected',
                        textAlign: TextAlign.center,
                        style: textTheme.labelLarge,
                      ),
                      backgroundColor: colorScheme.primary,
                    ),
                    Expanded(
                      child: _localLibraries!.isNotEmpty
                          ? RefreshIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2.0,
                              onRefresh: () async {
                                setState(() {
                                  _currentPage = 1;
                                  _futurePagedLibraries = appState
                                      .refreshLibraries!(appState, false);
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
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (_selectedIndex
                                                .contains(index)) {
                                              _selectedIndex.remove(index);
                                            } else {
                                              _selectedIndex.add(index);
                                            }
                                          });
                                        },
                                        child: SelectableLibraryItem(
                                          library: _localLibraries![index],
                                          inMultiSelectMode: true,
                                          isCreateLibraryItem: false,
                                          selected:
                                              _selectedIndex.contains(index),
                                        ),
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
                              'Empty libraries',
                              style: textTheme.labelMedium,
                            )),
                    ),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: _selectedIndex.isNotEmpty
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ShowConfirmDialog(
                                      title:
                                          'Do you want to remove these libraries?',
                                      onConfirm: () {
                                        Navigator.pop(context);
                                        _removeSelectedLibraries(appState);
                                      },
                                    ),
                                  );
                                }
                              : null,
                          style: _selectedIndex.isNotEmpty
                              ? ButtonStyle(
                                  shadowColor: MaterialStateProperty.all(
                                    colorScheme.primary,
                                  ),
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.grey,
                                  ),
                                )
                              : null,
                          child: Text(
                            'Remove',
                            style: _selectedIndex.isNotEmpty
                                ? textTheme.labelSmall
                                : textTheme.labelSmall!.copyWith(
                                    color: colorScheme.onSecondary
                                        .withOpacity(0.5),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
