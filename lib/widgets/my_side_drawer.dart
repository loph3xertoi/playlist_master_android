import 'dart:io';
import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../states/app_state.dart';
import '../utils/my_toast.dart';

class MySideDrawer extends StatefulWidget {
  @override
  State<MySideDrawer> createState() => _MySideDrawerState();
}

class _MySideDrawerState extends State<MySideDrawer> {
  late int _selectedIndex;
  ColorScheme? _colorScheme;
  TextTheme? _textTheme;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      print('Open Settings');
    } else if (index == 1) {
      _openFeedback();
    } else if (index == 2) {
      // https://github.com/loph3xertoi/playlist_master_android/issues
      final Uri toLaunch = Uri(
          scheme: 'https',
          host: 'github.com',
          path: '/loph3xertoi/playlist_master_android/issues');
      _openGithubIssues(toLaunch);
    } else if (index == 3) {
      print('Bug Report');
    } else {
      throw 'Invalid selected drawer item';
    }
  }

  void _openFeedback() {
    // BetterFeedback.of(context).isVisible
    BetterFeedback.of(context).show(
      (feedback) async {
        alertFeedbackFunction(
          context,
          feedback,
        );
      },
    );
  }

  Future<void> _openGithubIssues(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void alertFeedbackFunction(
    BuildContext outerContext,
    UserFeedback feedback,
  ) {
    showDialog<void>(
      context: outerContext,
      builder: (context) {
        return AlertDialog(
          title: Text(feedback.text, style: _textTheme!.labelMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (feedback.extra != null) Text(feedback.extra!.toString()),
                Image.memory(
                  feedback.screenshot,
                  height: 600,
                  width: 500,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                shadowColor: MaterialStateProperty.all(
                  _colorScheme!.primary,
                ),
                overlayColor: MaterialStateProperty.all(
                  Colors.grey,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('Close',
                  style: _textTheme!.labelSmall!.copyWith(color: Colors.red)),
            ),
            TextButton(
              style: ButtonStyle(
                shadowColor: MaterialStateProperty.all(
                  _colorScheme!.primary,
                ),
                overlayColor: MaterialStateProperty.all(
                  Colors.grey,
                ),
              ),
              onPressed: () async {
                // draft an email and send to developer
                final screenshotFilePath =
                    await writeImageToStorage(feedback.screenshot);
                print(screenshotFilePath);
                final Email email = Email(
                  body: feedback.text,
                  subject: 'Feedback: Playlist Master',
                  recipients: ['loph3xertoi@gmail.com'],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
                // Navigator.pop(context);
                MyToast.showToast('Feedback sent successfully');
              },
              child: Text('Submit',
                  style: _textTheme!.labelSmall!.copyWith(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuTile(String title, IconData icon, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    _colorScheme = colorScheme;
    _textTheme = textTheme;
    return ListTile(
      title: Text(
        title,
        style: textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
        ),
      ),
      leading: Icon(
        icon,
        color: colorScheme.onSecondary,
      ),
      onTap: () {
        if (title == 'Settings') {
          _selectedIndex = 0;
        } else if (title == 'Feedback') {
          _selectedIndex = 1;
        } else if (title == 'Open Github Issues') {
          _selectedIndex = 2;
        } else if (title == 'Bug Report') {
          _selectedIndex = 3;
        } else {
          throw 'Invalid selected drawer item';
        }
        _onItemTapped(_selectedIndex);
      },
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SizedBox(
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                // color: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      accountName: Text(
                        'Daw Loph',
                        style: textTheme.labelMedium,
                      ),
                      accountEmail: Text(
                        'loph3xertoi@gmail.com',
                        style: textTheme.labelMedium,
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: AssetImage(
                          currentPlatform == 0
                              ? 'assets/images/pm_round.png'
                              : currentPlatform == 1
                                  ? 'assets/images/qqmusic.png'
                                  : currentPlatform == 2
                                      ? 'assets/images/netease.png'
                                      : 'assets/images/bilibili.png',
                        ),
                        backgroundColor: colorScheme.onSecondary,
                      ),
                      otherAccountsPictures: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            currentPlatform == 0
                                ? 'assets/images/qqmusic.png'
                                : currentPlatform == 1
                                    ? 'assets/images/netease.png'
                                    : currentPlatform == 2
                                        ? 'assets/images/bilibili.png'
                                        : 'assets/images/qqmusic.png',
                          ),
                        ),
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            currentPlatform == 0
                                ? 'assets/images/netease.png'
                                : currentPlatform == 1
                                    ? 'assets/images/bilibili.png'
                                    : currentPlatform == 2
                                        ? 'assets/images/qqmusic.png'
                                        : 'assets/images/netease.png',
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildMenuTile('Settings', Icons.settings_rounded,
                              _selectedIndex == 0),
                          _buildMenuTile('Feedback', Icons.feedback_rounded,
                              _selectedIndex == 1),
                          _buildMenuTile('Open Github Issues', MdiIcons.github,
                              _selectedIndex == 2),
                          _buildMenuTile('Bug Report', Icons.bug_report_rounded,
                              _selectedIndex == 3),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Log out',
                        style: textTheme.labelMedium,
                      ),
                      leading:
                          Icon(Icons.logout, color: colorScheme.onSecondary),
                      onTap: () {
                        print(appState);
                        // TODO: Implement log out functionality
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }
}
