import 'dart:async';
import 'dart:math';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/bilibili/bili_fav_list.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/dto/result.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import 'confirm_popup.dart';
import 'select_favlist_popup.dart';
import 'selectable_resource_item.dart';

class MultiResourcesSelectPopup extends StatefulWidget {
  const MultiResourcesSelectPopup({
    super.key,
    this.inSimilarResourcesPage = false,
    this.similarResources = const [],
  });

  final bool inSimilarResourcesPage;
  final List<BiliResource> similarResources;

  @override
  State<MultiResourcesSelectPopup> createState() =>
      _MultiResourcesSelectPopupState();
}

class _MultiResourcesSelectPopupState extends State<MultiResourcesSelectPopup> {
  List<int> _selectedIndex = [];

  void _addResourcesToFavLists(
      BuildContext context, MyAppState appState) async {
    List<BiliResource> selectedResources = widget.inSimilarResourcesPage
        ? _selectedIndex.map((index) => widget.similarResources[index]).toList()
        : _selectedIndex
            .map((index) => appState.rawResourcesInFavList![index])
            .toList();
    if (mounted) {
      List<Future<Result?>>? list =
          await showFlexibleBottomSheet<List<Future<Result?>>>(
        minHeight: 0,
        initHeight: 0.45,
        maxHeight: 0.9,
        context: context,
        bottomSheetColor: Colors.transparent,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return SelectFavListPopup(
            scrollController: scrollController,
            resources: selectedResources,
            action: 'add',
            biliSourceFavListId: (appState.rawOpenedLibrary as BiliFavList).id,
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
      if (list != null) {
        List<Result?> results = await Future.wait<Result?>(list);
        for (Result? result in results) {
          if (result != null && result.success) {
            Timer(Duration(milliseconds: 1500), () {
              appState.refreshDetailFavListPage!(appState);
              appState.refreshLibraries!(appState, true);
            });
            MyToast.showToast('Add resources successfully');
            break;
          }
        }
      }
    }
  }

  void _removeSelectedResourcesFromFavList(MyAppState appState) async {
    appState.rawOpenedLibrary!.itemCount -= _selectedIndex.length;
    if (appState.rawOpenedLibrary!.itemCount == 0 && mounted) {
      Navigator.pop(context);
    }
    Map<int, Object> map = appState.rawResourcesInFavList!.asMap();
    Map<int, Object> modifiableMap = Map.from(map);
    List<BiliResource> removedResources = _selectedIndex
        .map((index) => appState.rawResourcesInFavList![index])
        .toList();
    modifiableMap
        .removeWhere((index, object) => _selectedIndex.contains(index));
    appState.rawResourcesInFavList = modifiableMap.values.toList();
    setState(() {
      _selectedIndex.clear();
    });
    appState.searchedResources = appState.rawResourcesInFavList!;
    await appState.removeResourcesFromFavList(
        removedResources, appState.openedLibrary!, appState.currentPlatform);
    Timer(Duration(milliseconds: 1500), () {
      appState.refreshDetailFavListPage!(appState);
      appState.refreshLibraries!(appState, true);
    });
  }

  void _moveResourcesToFavLists(
      BuildContext context, MyAppState appState) async {
    List<BiliResource> selectedResources = _selectedIndex
        .map((index) => appState.rawResourcesInFavList![index])
        .toList();
    List<Future<Result?>>? list =
        await showFlexibleBottomSheet<List<Future<Result?>>>(
      minHeight: 0,
      initHeight: 0.45,
      maxHeight: 0.9,
      context: context,
      bottomSheetColor: Colors.transparent,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      builder: (
        BuildContext context,
        ScrollController scrollController,
        double bottomSheetOffset,
      ) {
        return SelectFavListPopup(
          scrollController: scrollController,
          resources: selectedResources,
          action: 'move',
          biliSourceFavListId: (appState.rawOpenedLibrary as BiliFavList).id,
        );
      },
      anchors: [0, 0.45, 0.9],
      isSafeArea: true,
    );

    if (list != null) {
      List<Result?> results = await Future.wait<Result?>(list);
      for (Result? result in results) {
        if (result != null && result.success) {
          appState.rawOpenedLibrary!.itemCount -= _selectedIndex.length;
          if (appState.rawOpenedLibrary!.itemCount == 0 && mounted) {
            Navigator.pop(context);
          }
          Map<int, Object> map = appState.rawResourcesInFavList!.asMap();
          Map<int, Object> modifiableMap = Map.from(map);
          modifiableMap
              .removeWhere((index, object) => _selectedIndex.contains(index));
          appState.rawResourcesInFavList = modifiableMap.values.toList();
          setState(() {
            _selectedIndex.clear();
          });
          appState.searchedResources = appState.rawResourcesInFavList!;
          Timer(Duration(milliseconds: 1500), () {
            appState.refreshDetailFavListPage!(appState);
            appState.refreshLibraries!(appState, true);
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    int resourcesCount = widget.inSimilarResourcesPage
        ? widget.similarResources.length
        : appState.openedLibrary!.itemCount;
    var inSimilarResourcesPage = widget.inSimilarResourcesPage;
    var similarResources = widget.similarResources;
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
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedIndex.length < resourcesCount) {
                          _selectedIndex.clear();
                          _selectedIndex =
                              List.generate(resourcesCount, (index) => index);
                        } else {
                          _selectedIndex.clear();
                        }
                      });
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
                      _selectedIndex.length < resourcesCount
                          ? 'Select all'
                          : 'Unselect all',
                      style: textTheme.labelSmall,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _selectedIndex.isEmpty
                        ? appState.openedLibrary!.name
                        : '${_selectedIndex.length} resources selected',
                    textAlign: TextAlign.center,
                    style: textTheme.labelLarge,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                      'Finish',
                      style: textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: isUsingMockData
                    ? min(appState.rawResourcesInFavList!.length, 10)
                    : inSimilarResourcesPage
                        ? similarResources.length
                        : appState.rawResourcesInFavList!.length,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (_selectedIndex.contains(index)) {
                            _selectedIndex.remove(index);
                          } else {
                            _selectedIndex.add(index);
                          }
                        });
                      },
                      child: SelectableResourceItem(
                        index: index,
                        isSelected: _selectedIndex.contains(index),
                        resource: inSimilarResourcesPage
                            ? similarResources[index]
                            : appState.rawResourcesInFavList![index],
                      ),
                    ),
                  );
                },
              ),
            ),
            ButtonBar(
              children: <Widget>[
                !inSimilarResourcesPage
                    ? TextButton(
                        onPressed: _selectedIndex.isNotEmpty
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ShowConfirmDialog(
                                    title:
                                        'Do you want to remove these resources from favlist?',
                                    onConfirm: () {
                                      _removeSelectedResourcesFromFavList(
                                          appState);
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
                                  color:
                                      colorScheme.onSecondary.withOpacity(0.5),
                                ),
                        ),
                      )
                    : Container(),
                TextButton(
                  onPressed: _selectedIndex.isNotEmpty
                      ? () {
                          _addResourcesToFavLists(context, appState);
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
                    'Add to',
                    style: _selectedIndex.isNotEmpty
                        ? textTheme.labelSmall
                        : textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSecondary.withOpacity(0.5),
                          ),
                  ),
                ),
                !inSimilarResourcesPage
                    ? TextButton(
                        onPressed: _selectedIndex.isNotEmpty
                            ? () {
                                _moveResourcesToFavLists(context, appState);
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
                          'Move to',
                          style: _selectedIndex.isNotEmpty
                              ? textTheme.labelSmall
                              : textTheme.labelSmall!.copyWith(
                                  color:
                                      colorScheme.onSecondary.withOpacity(0.5),
                                ),
                        ),
                      )
                    : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
