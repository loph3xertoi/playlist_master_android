import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import 'create_library_popup.dart';
import 'libraries_settings_menu_popup.dart';
import 'library_item.dart';

class MyContentArea extends StatefulWidget {
  @override
  State<MyContentArea> createState() => _MyContentAreaState();
}

class _MyContentAreaState extends State<MyContentArea> {
  late Future<List<BasicLibrary>?> _libraries;

  Future<List<BasicLibrary>?> _refreshLibraries(
      MyAppState appState, bool delayRebuild) async {
    _libraries = appState.fetchLibraries(appState.currentPlatform);
    if (delayRebuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    } else {
      setState(() {});
    }

    return _libraries;
  }

  void _removeLibraryFromLibraries(BasicLibrary library) async {
    List<BasicLibrary>? libraries = await _libraries;
    libraries!.remove(library);
    setState(() {
      _libraries = Future.value(libraries);
    });
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      _libraries = Future.value(MockData.libraries);
    } else {
      _libraries = state.fetchLibraries(state.currentPlatform);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.refreshLibraries = _refreshLibraries;
      state.removeLibraryFromLibraries = _removeLibraryFromLibraries;
    });
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
        future: _libraries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    '${snapshot.error}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
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
                      color: colorScheme.onPrimary,
                    ),
                    label: Text(
                      'Retry',
                      style: textTheme.labelMedium!.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _libraries =
                            appState.fetchLibraries(appState.currentPlatform);
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            List<BasicLibrary> libraries = snapshot.data as List<BasicLibrary>;
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
                            'Create Libraries (${libraries.length})',
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
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => CreateLibraryDialog(),
                              );
                            },
                          ),
                          IconButton(
                            color: colorScheme.tertiary,
                            icon: Icon(Icons.more_vert_rounded),
                            tooltip: 'Library settings',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => LibrariesSettingsPopup(
                                  libraries: libraries,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ]),
                  ),
                  Expanded(
                    child: libraries.isNotEmpty
                        ? ListView.builder(
                            itemCount: libraries.length,
                            itemBuilder: (context, index) {
                              return LibraryItem(
                                library: libraries[index],
                              );
                            },
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
}
