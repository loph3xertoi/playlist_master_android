import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../states/app_state.dart';
import 'library_item_menu_popup.dart';

class LibraryItem extends StatelessWidget {
  final BasicLibrary library;
  const LibraryItem({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          appState.rawOpenedLibrary = library;
          appState.openedLibrary = library;
          appState.rawQueue = [];
          Navigator.pushNamed(
            context,
            '/detail_library_page',
          );
        },
        child: Ink(
          height: 60.0,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13.0, 7.0, 0.0, 7.0),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: SizedBox(
                    width: 46.0,
                    height: 46.0,
                    child: isUsingMockData
                        ? Image.asset(library.cover)
                        : CachedNetworkImage(
                            imageUrl: library.cover.isNotEmpty
                                ? library.cover
                                : MyAppState.defaultLibraryCover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(MdiIcons.debian),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            library.name,
                            style:
                                textTheme.labelSmall!.copyWith(fontSize: 13.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${library.itemCount} songs',
                          style: textTheme.labelSmall!.copyWith(fontSize: 11.0),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => LibraryItemMenuPopup(
                          library: library,
                          isInDetailLibraryPage: false,
                        ),
                      );
                    },
                    color: colorScheme.tertiary,
                    icon: Icon(
                      Icons.more_vert_rounded,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
