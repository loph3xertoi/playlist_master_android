// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:playlistmaster/pages/settings_page.dart';
import 'package:playlistmaster/utils/app_updater.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({Key? key}) : super(key: key);

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/pm_icon_inapp.png',
              width: 80.0,
              height: 80.0,
            ),
          ),
          Text('Version: ${AppUpdater.currentVersionNumber}'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  SettingItem(
                    name: 'Check for updates',
                    style: textTheme.labelMedium!,
                    onTap: (context) {
                      AppUpdater.checkForUpdate();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
