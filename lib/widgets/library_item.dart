import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import 'library_item_menu_popup.dart';

class LibraryItem extends StatelessWidget {
  final BasicLibrary library;
  const LibraryItem({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          appState.rawOpenedLibrary = library;
          appState.openedLibrary = library;
          appState.rawSongsInLibrary = [];
          if (appState.currentPlatform != 3) {
            Navigator.pushNamed(
              context,
              '/detail_library_page',
            );
          } else {
            Navigator.pushNamed(
              context,
              '/detail_favlist_page',
            );
          }
        },
        child: SizedBox(
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
                                ? kIsWeb
                                    ? API.convertImageUrl(library.cover)
                                    : library.cover
                                : MyAppState.defaultLibraryCover,
                            httpHeaders: {
                              'Cookie': MyAppState.cookie!,
                              'User-Agent':
                                  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
                            },
                            cacheManager: MyHttp.myImageCacheManager,
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
                    tooltip: 'Edit library',
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
