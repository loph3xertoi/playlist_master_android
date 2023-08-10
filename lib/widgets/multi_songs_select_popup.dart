import 'dart:math';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../entities/dto/result.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import 'confirm_popup.dart';
import 'select_library_popup.dart';
import 'selectable_song_item.dart';

class MultiSongsSelectPopup extends StatefulWidget {
  const MultiSongsSelectPopup({
    super.key,
    this.inSimilarSongsPage = false,
    this.similarSongs = const [],
  });

  final bool inSimilarSongsPage;
  final List<BasicSong> similarSongs;

  @override
  State<MultiSongsSelectPopup> createState() => _MultiSongsSelectPopupState();
}

class _MultiSongsSelectPopupState extends State<MultiSongsSelectPopup> {
  List<int> _selectedIndex = [];

  void _addSongsToLibraries(BuildContext context, MyAppState appState) async {
    List<BasicSong> selectedSongs = widget.inSimilarSongsPage
        ? _selectedIndex.map((index) => widget.similarSongs[index]).toList()
        : _selectedIndex
            .map((index) => appState.rawSongsInLibrary![index])
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
          return SelectLibraryPopup(
            scrollController: scrollController,
            songs: selectedSongs,
            action: 'add',
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
      if (list != null) {
        List<Result?> results = await Future.wait<Result?>(list);
        for (Result? result in results) {
          if (result != null && result.success) {
            appState.refreshLibraries!(appState, true);
            MyToast.showToast('Add songs successfully');
            break;
          }
        }
      }
    }
  }

  void _removeSelectedSongsFromLibrary(MyAppState appState) async {
    appState.rawOpenedLibrary!.itemCount -= _selectedIndex.length;
    if (appState.rawOpenedLibrary!.itemCount == 0 && mounted) {
      Navigator.pop(context);
    }
    Map<int, Object> map = appState.rawSongsInLibrary!.asMap();
    Map<int, Object> modifiableMap = Map.from(map);
    List<BasicSong> removedSongs = _selectedIndex
        .map((index) => appState.rawSongsInLibrary![index])
        .toList();
    modifiableMap
        .removeWhere((index, object) => _selectedIndex.contains(index));
    appState.rawSongsInLibrary = modifiableMap.values.toList();
    setState(() {
      _selectedIndex.clear();
    });
    appState.searchedSongs = appState.rawSongsInLibrary!;
    await appState.removeSongsFromLibrary(
        removedSongs, appState.openedLibrary!, appState.currentPlatform);
    appState.refreshLibraries!(appState, true);
    appState.refreshDetailLibraryPage!(appState);
  }

  void _moveSongsToLibraries(BuildContext context, MyAppState appState) async {
    List<BasicSong> selectedSongs = _selectedIndex
        .map((index) => appState.rawSongsInLibrary![index])
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
        return SelectLibraryPopup(
          scrollController: scrollController,
          songs: selectedSongs,
          action: 'move',
        );
      },
      anchors: [0, 0.45, 0.9],
      isSafeArea: true,
    );

// if (list != null) {
//         List<Result> results = await Future.wait<Result>(list);
//         for (Result result in results) {
//           if (result.success) {
//             appState.refreshLibraries!(appState, true);
//             MyToast.showToast('Add songs successfully');
//             break;
//           }
//         }
//       }

    if (list != null) {
      List<Result?> results = await Future.wait<Result?>(list);
      for (Result? result in results) {
        if (result != null && result.success) {
          appState.rawOpenedLibrary!.itemCount -= _selectedIndex.length;
          if (appState.rawOpenedLibrary!.itemCount == 0 && mounted) {
            Navigator.pop(context);
          }
          Map<int, Object> map = appState.rawSongsInLibrary!.asMap();
          Map<int, Object> modifiableMap = Map.from(map);
          modifiableMap
              .removeWhere((index, object) => _selectedIndex.contains(index));
          appState.rawSongsInLibrary = modifiableMap.values.toList();
          setState(() {
            _selectedIndex.clear();
          });
          appState.searchedSongs = appState.rawSongsInLibrary!;
          // await appState.removeSongsFromLibrary(
          //     selectedSongs, appState.openedLibrary!, appState.currentPlatform);
          appState.refreshLibraries!(appState, true);
          appState.refreshDetailLibraryPage!(appState);
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
    int songsCount = widget.inSimilarSongsPage
        ? widget.similarSongs.length
        : appState.openedLibrary!.itemCount;
    var inSimilarSongsPage = widget.inSimilarSongsPage;
    var similarSongs = widget.similarSongs;
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
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: isUsingMockData
                    ? min(appState.rawSongsInLibrary!.length, 10)
                    : inSimilarSongsPage
                        ? similarSongs.length
                        : appState.rawSongsInLibrary!.length,
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
                        song: inSimilarSongsPage
                            ? similarSongs[index]
                            : appState.rawSongsInLibrary![index],
                      ),
                    ),
                  );
                },
              ),
            ),
            ButtonBar(
              children: <Widget>[
                !inSimilarSongsPage
                    ? TextButton(
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
                                  color:
                                      colorScheme.onSecondary.withOpacity(0.5),
                                ),
                        ),
                      )
                    : Container(),
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
                !inSimilarSongsPage
                    ? TextButton(
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
