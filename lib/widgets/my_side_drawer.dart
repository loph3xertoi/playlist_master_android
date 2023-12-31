import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log_export/log_export.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/secrets.dart';
import '../config/user_info.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import 'confirm_popup.dart';

class MySideDrawer extends StatefulWidget {
  @override
  State<MySideDrawer> createState() => _MySideDrawerState();
}

class _MySideDrawerState extends State<MySideDrawer> {
  late int _selectedIndex;
  ColorScheme? _colorScheme;
  TextTheme? _textTheme;
  MyAppState? _appState;

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
      Navigator.pop(context);
      Navigator.pushNamed(context, '/settings');
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
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        showDialog(
            context: context,
            builder: (_) => ShowConfirmDialog(
                  title:
                      'Do you want to upload the crash logs, which is only used for debugging purposes?',
                  onConfirm: () {
                    print('Upload crash logs');
                    _reportBugs();
                  },
                ));
      } else {
        MyToast.showToast('Only support android and ios');
      }
    } else if (index == 4) {
      // showDialog(context: context, builder: (_) => LicensePage());
      // showLicensePage(context: context);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => Theme(
              data: Theme.of(context).copyWith(
                  appBarTheme: Theme.of(context).appBarTheme.copyWith(
                        titleTextStyle: _textTheme!.labelLarge,
                        color: _colorScheme!.primary,
                        iconTheme:
                            IconThemeData(color: _colorScheme!.onSecondary),
                      ),
                  cardColor: _colorScheme!.primary,
                  textTheme: TextTheme(
                    headlineSmall: _textTheme!.labelLarge!.copyWith(
                      fontSize: 26.0,
                    ),
                    bodyLarge: _textTheme!.labelMedium!,
                    bodyMedium: _textTheme!.labelSmall!,
                  ),
                  listTileTheme: ListTileThemeData(
                    textColor: _colorScheme!.onSecondary,
                  )),
              child: LicensePage()),
        ),
      );
    } else {
      throw 'Invalid selected drawer item';
    }
  }

  void _openFeedback() {
    // BetterFeedback.of(context).isVisible
    BetterFeedback.of(context).show(
      (feedback) async {
        _alertFeedbackFunction(
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

  Future<void> _reportBugs() async {
    File crashLog = await _getCrashLog();
    final smtpServer = SmtpServer(mySmtpServer,
        // port: 587, works in backend
        port: 465, // works in pm client
        ssl: true,
        username: bugSenderEmail,
        password: smtpServerPassword);
    final message = Message()
      ..from = Address(bugSenderEmail, 'Bug Reporter')
      ..recipients.add(myEmail)
      ..subject = 'Bug Report: Playlist Master'
      ..attachments = [FileAttachment(crashLog)];
    try {
      final sendReport = await send(message, smtpServer);
      print('Upload crash report successfully: $sendReport');
      MyToast.showToast('Upload crash report successfully: $sendReport');
    } on MailerException catch (e) {
      print('Fail to upload crash report: $e');
      MyToast.showToast('Fail to upload crash report: $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future<File> _getCrashLog() async {
    try {
      final logFileExportedPath =
          await LogExport.getLogFileExportedPath() ?? '';
      if (logFileExportedPath.isNotEmpty) {
        var encoder = ZipFileEncoder();
        final Directory output = await getTemporaryDirectory();
        String logsPath = '${output.path}/logs.zip';
        encoder.create(logsPath);
        encoder.addFile(File(logFileExportedPath));
        encoder.close();
        return File(logsPath);
      } else {
        throw 'Failed to export log file';
      }
    } catch (e, s) {
      print('Export log error $e $s');
      rethrow;
    }
  }

  void _alertFeedbackFunction(
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
                    await _writeImageToStorage(feedback.screenshot);
                print(screenshotFilePath);
                final Email email = Email(
                  body: feedback.text,
                  subject: 'Feedback: Playlist Master',
                  recipients: [myEmail],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
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
        } else if (title == 'Open GitHub Issues') {
          _selectedIndex = 2;
        } else if (title == 'Bug Report') {
          _selectedIndex = 3;
        } else if (title == 'Licenses') {
          _selectedIndex = 4;
        } else {
          throw 'Invalid selected drawer item';
        }
        _onItemTapped(_selectedIndex);
      },
      textColor: Colors.white,
    );
  }

  Future<String> _writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  Future<bool> _goToLogin(BuildContext context) {
    return Navigator.of(context)
        .pushReplacementNamed('/login_page')
        // we dont want to pop the screen, just replace it completely
        .then((_) => false);
  }

  void _logout() {
    showDialog(
        context: context,
        builder: (_) => ShowConfirmDialog(
              title: 'Do you want to logout?',
              onConfirm: () async {
                print('Logout...');
                _appState!.logout();
                if (UserInfo.basicUser!.loginType == 2) {
                  GoogleSignIn googleSignIn =
                      GoogleSignIn(serverClientId: googleClientId);
                  // Revoke google oauth2 authorization.
                  var googleSignInAccount = await googleSignIn.signOut();
                }
                if (mounted) {
                  _goToLogin(context);
                }
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
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
                        '${UserInfo.basicUser!.name}(${UserInfo.uid}) (${UserInfo.basicUser!.role})',
                        style: textTheme.labelMedium,
                      ),
                      accountEmail: Text(
                        UserInfo.basicUser!.email ?? '',
                        style: textTheme.labelMedium,
                      ),
                      currentAccountPicture: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircleAvatar(
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
                          UserInfo.basicUser!.loginType == 0 ||
                                  UserInfo.basicUser!.loginType == 1 ||
                                  UserInfo.basicUser!.loginType == 2
                              ? Positioned(
                                  bottom: 0.0,
                                  right: 0.0,
                                  child: SizedBox(
                                    width: 22.0,
                                    height: 22.0,
                                    child: Icon(
                                      UserInfo.basicUser!.loginType == 0
                                          ? MdiIcons.email
                                          : UserInfo.basicUser!.loginType == 1
                                              ? MdiIcons.github
                                              : MdiIcons.google,
                                      color: colorScheme.onSecondary,
                                    ),
                                  ))
                              : Container(),
                        ],
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
                          _buildMenuTile('Open GitHub Issues', MdiIcons.github,
                              _selectedIndex == 2),
                          _buildMenuTile('Bug Report', Icons.bug_report_rounded,
                              _selectedIndex == 3),
                          _buildMenuTile('Licenses', MdiIcons.license,
                              _selectedIndex == 4),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Log out',
                        style: textTheme.labelMedium!.copyWith(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold),
                      ),
                      leading: Icon(Icons.logout, color: Colors.red.shade900),
                      onTap: _logout,
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
}
