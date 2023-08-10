import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/bilibili/bili_resource.dart';
import '../states/app_state.dart';
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
    appState.refreshLibraries!(appState, true);
    appState.refreshDetailLibraryPage!(appState);
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
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                Navigator.pop(context, 'Add to library');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.playlist_add_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        Navigator.pop(context, 'Add to library');
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Add to library',
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
                              'Do you want to remove this resource from library?',
                          onConfirm: () {
                            print('Remove from library.');
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
                                      'Do you want to remove this resource from library?',
                                  onConfirm: () {
                                    print('Remove from library.');
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
                              'Remove from library',
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
                Navigator.popAndPushNamed(context, '/related_videos_page',
                    arguments: widget.resource);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.ondemand_video_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        Navigator.popAndPushNamed(
                            context, '/related_videos_page',
                            arguments: widget.resource);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Play video',
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
                appState.isResourcesPlayerPageOpened = false;
                BasicLibrary originLibrary = appState.openedLibrary!;
                appState.openedLibrary = BasicLibrary(
                  name: 'similar resource',
                  cover: '',
                  itemCount: -1,
                );
                Navigator.popAndPushNamed(context, '/similar_resources_page',
                        arguments: widget.resource)
                    .then((_) => appState.openedLibrary = originLibrary);
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
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                print('resource\'s detail');
                appState.isResourcesPlayerPageOpened = false;
                Navigator.popAndPushNamed(context, '/detail_resource_page');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.description_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        appState.isResourcesPlayerPageOpened = false;
                        Navigator.popAndPushNamed(
                            context, '/detail_resource_page');
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Resource\'s detail',
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
