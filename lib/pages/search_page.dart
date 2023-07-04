import 'package:flutter/material.dart';
import 'package:playlistmaster/states/my_search_state.dart';
import 'package:playlistmaster/utils/theme_manager.dart';
import 'package:playlistmaster/widgets/my_searchbar.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: ChangeNotifierProvider(
            create: (context) => MySearchState(),
            child: Column(
              children: [
                Container(
                  color: colorScheme.primary,
                  child: MySearchBar(
                    myScaffoldKey: _scaffoldKey,
                    notInHomepage: true,
                    inPlaylistDetailPage: false,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.playlistDetailPageBg!,
                        stops: [0.0, 0.33, 0.67, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                      child: Placeholder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
