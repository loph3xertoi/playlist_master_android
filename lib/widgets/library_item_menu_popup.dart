import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../states/app_state.dart';
import 'confirm_popup.dart';

class LibraryItemMenuPopup extends StatelessWidget {
  final BasicLibrary library;
  final bool isInDetailLibraryPage;
  LibraryItemMenuPopup(
      {required this.library, required this.isInDetailLibraryPage});

  void _deleteLibrary(MyAppState appState) async {
    int platform = appState.currentPlatform;
    await appState.deleteLibraries([library], platform);
    appState.refreshLibraries!(appState, false);
    // appState.removeLibraryFromLibraries!(library);
  }

  void _editLibrary(MyAppState appState) async {
    int platform = appState.currentPlatform;
    if (platform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (platform == 1) {
      throw UnimplementedError('API missing in qq music platform');
    } else if (platform == 2) {
      throw UnimplementedError('API missing in ncm platform');
    } else if (platform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
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
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  library.name,
                  style: textTheme.labelMedium,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => ShowConfirmDialog(
                    title: 'Do you want to delete this library?',
                    onConfirm: () {
                      print('Delete library.');
                      print(appState);
                      _deleteLibrary(appState);
                      Navigator.pop(context);
                      if (isInDetailLibraryPage) {
                        appState.openedLibrary = null;
                        appState.rawOpenedLibrary = null;
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ShowConfirmDialog(
                            title: 'Do you want to delete this library?',
                            onConfirm: () {
                              print('Delete library.');
                              print(appState);
                              _deleteLibrary(appState);
                              Navigator.pop(context);
                              if (isInDetailLibraryPage) {
                                appState.openedLibrary = null;
                                appState.rawOpenedLibrary = null;
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Delete',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                print('Edit library.');
                print(appState);
                _editLibrary(appState);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        print('Edit library.');
                        print(appState);
                        _editLibrary(appState);
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Edit',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
