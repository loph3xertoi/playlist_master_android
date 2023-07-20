import 'dart:math';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../states/app_state.dart';
import 'confirm_popup.dart';
import 'select_library_popup.dart';
import 'selectable_song_item.dart';

class MultiSongsSelectPopup extends StatefulWidget {
  @override
  State<MultiSongsSelectPopup> createState() => _MultiSongsSelectPopupState();
}

class _MultiSongsSelectPopupState extends State<MultiSongsSelectPopup> {
  List<int> _selectedIndex = [];
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    int songsCount = appState.openedLibrary!.itemCount;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                        if (_selectedIndex.length < songsCount) {
                          _selectedIndex.clear();
                          _selectedIndex =
                              List.generate(songsCount, (index) => index);
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
                      _selectedIndex.length < songsCount
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
                        : '${_selectedIndex.length} songs selected',
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
                itemCount: isUsingMockData
                    ? min(appState.rawQueue!.length, 10)
                    : appState.rawQueue!.length,
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
                      child: SelectableSongItem(
                        index: index,
                        isSelected: _selectedIndex.contains(index),
                        song: appState.rawQueue![index],
                      ),
                    ),
                  );
                },
              ),
            ),
            ButtonBar(
              children: <Widget>[
                TextButton(
                  onPressed: _selectedIndex.isNotEmpty
                      ? () {
                          showDialog(
                            context: context,
                            builder: (_) => ShowConfirmDialog(
                              title:
                                  'Do you want to remove these songs from library?',
                              onConfirm: () {
                                _removeSelectedSongsFromLibrary(appState);
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
                            color: colorScheme.onSecondary.withOpacity(0.5),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: _selectedIndex.isNotEmpty
                      ? () {
                          _addSongsToLibraries(context, appState);
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
                TextButton(
                  onPressed: _selectedIndex.isNotEmpty
                      ? () {
                          _moveSongsToLibraries(context, appState);
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
                            color: colorScheme.onSecondary.withOpacity(0.5),
                          ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _addSongsToLibraries(BuildContext context, MyAppState appState) async {
    List<BasicSong> selectedSongs =
        _selectedIndex.map((index) => appState.rawQueue![index]).toList();
    if (mounted) {
      showFlexibleBottomSheet(
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
          return SelectLibraryPopup(
            scrollController: scrollController,
            songs: selectedSongs,
            action: 'add',
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
    }
  }

  void _removeSelectedSongsFromLibrary(MyAppState appState) async {
    appState.rawOpenedLibrary!.itemCount -= _selectedIndex.length;
    Map<int, Object> map = appState.rawQueue!.asMap();
    Map<int, Object> modifiableMap = Map.from(map);
    List<BasicSong> removedSongs =
        _selectedIndex.map((index) => appState.rawQueue![index]).toList();
    modifiableMap
        .removeWhere((index, object) => _selectedIndex.contains(index));
    appState.rawQueue = modifiableMap.values.toList();
    setState(() {
      _selectedIndex.clear();
    });
    appState.searchedSongs = appState.rawQueue!;
    await appState.removeSongsFromLibrary(
        removedSongs, appState.openedLibrary!, appState.currentPlatform);
    appState.refreshLibraries!(appState, true);
    appState.refreshDetailLibraryPage!(appState);
    if (appState.rawOpenedLibrary!.itemCount == 0 && mounted) {
      Navigator.pop(context);
    }
  }

  void _moveSongsToLibraries(BuildContext context, MyAppState appState) async {
    List<BasicSong> selectedSongs =
        _selectedIndex.map((index) => appState.rawQueue![index]).toList();
    if (mounted) {
      int? result = await showFlexibleBottomSheet(
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
          return SelectLibraryPopup(
            scrollController: scrollController,
            songs: selectedSongs,
            action: 'move',
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );

      if (result != null && result == 0) {
        appState.rawOpenedLibrary!.itemCount -= _selectedIndex.length;
        Map<int, Object> map = appState.rawQueue!.asMap();
        Map<int, Object> modifiableMap = Map.from(map);
        modifiableMap
            .removeWhere((index, object) => _selectedIndex.contains(index));
        appState.rawQueue = modifiableMap.values.toList();
        setState(() {
          _selectedIndex.clear();
        });
        appState.searchedSongs = appState.rawQueue!;
        await appState.removeSongsFromLibrary(
            selectedSongs, appState.openedLibrary!, appState.currentPlatform);
        appState.refreshLibraries!(appState, true);
        appState.refreshDetailLibraryPage!(appState);
        if (appState.rawOpenedLibrary!.itemCount == 0 && mounted) {
          Navigator.pop(context);
        }
      }
    }
  }
}
