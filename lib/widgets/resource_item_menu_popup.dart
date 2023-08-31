import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/bilibili/bili_resource.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import 'confirm_popup.dart';

class CreateResourceItemMenuDialog extends StatefulWidget {
  CreateResourceItemMenuDialog({required this.resource});

  final BiliResource resource;

  @override
  State<CreateResourceItemMenuDialog> createState() =>
      _CreateResourceItemMenuDialogState();
}

class _CreateResourceItemMenuDialogState
    extends State<CreateResourceItemMenuDialog> {
  void _removeResourceFromLibrary(
      BuildContext context, MyAppState appState) async {
    appState.rawOpenedLibrary!.itemCount -= 1;
    appState.rawResourcesInFavList!.remove(widget.resource);
    appState.searchedResources.remove(widget.resource);
    await appState.removeResourcesFromFavList(
        [widget.resource], appState.openedLibrary!, appState.currentPlatform);
    Timer(Duration(milliseconds: 1500), () {
      // if (mounted) {
      if (appState.searchedCount == 0) {
        appState.refreshDetailFavListPage != null
            ? appState.refreshDetailFavListPage!(appState)
            : null;
      }
      appState.refreshLibraries != null
          ? appState.refreshLibraries!(appState, true)
          : null;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
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
            if (appState.currentPlatform != 0)
              InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                onTap: () {
                  Navigator.pop(context, 'Add to pms');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.playlist_add_rounded),
                        color: colorScheme.tertiary,
                        onPressed: () {
                          Navigator.pop(context, 'Add to pms');
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Add to pms',
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
                Navigator.pop(context, 'Add to favlist');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.playlist_add_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        Navigator.pop(context, 'Add to favlist');
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Add to favlist',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            appState.openedLibrary!.itemCount > 0
                ? InkWell(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShowConfirmDialog(
                          title:
                              'Do you want to remove this resource from favlist?',
                          onConfirm: () {
                            print('Remove from favlist.');
                            _removeResourceFromLibrary(context, appState);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.playlist_remove_rounded),
                            color: colorScheme.tertiary,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ShowConfirmDialog(
                                  title:
                                      'Do you want to remove this resource from favlist?',
                                  onConfirm: () {
                                    print('Remove from favlist.');
                                    _removeResourceFromLibrary(
                                        context, appState);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Remove from favlist',
                              style: textTheme.labelMedium!.copyWith(
                                color: colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                MyToast.showToast('To be implement');
                throw UnimplementedError('To be implement');
                // appState.isResourcesPlayerPageOpened = false;
                // BasicLibrary originLibrary = appState.openedLibrary!;
                // appState.openedLibrary = BasicLibrary(
                //   name: 'similar resource',
                //   cover: '',
                //   itemCount: -1,
                // );
                // Navigator.popAndPushNamed(context, '/similar_resources_page',
                //         arguments: widget.resource)
                //     .then((_) => appState.openedLibrary = originLibrary);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.library_music_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        appState.isResourcesPlayerPageOpened = false;
                        BasicLibrary originLibrary = appState.openedLibrary!;
                        appState.openedLibrary = BasicLibrary(
                          name: 'similar resource',
                          cover: '',
                          itemCount: -1,
                        );
                        Navigator.popAndPushNamed(
                                context, '/similar_resources_page',
                                arguments: widget.resource)
                            .then(
                                (_) => appState.openedLibrary = originLibrary);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Similar resources',
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
