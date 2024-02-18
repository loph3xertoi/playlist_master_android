import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_update/flutter_app_update.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import '../http/api.dart';
import '../main.dart';
import 'my_logger.dart';
import 'my_toast.dart';

class AppUpdater {
  static String updateUrl = '';
  static String apkName = '';
  static String currentVersionNumber = '';
  static String? latestUpdateLog = '';
  static double ratio = 0;
  static bool isUpdateClicked = false;

  static void checkForUpdate() async {
    currentVersionNumber = await AzhonAppUpdate.getVersionName;
    String currentVersionName = 'v$currentVersionNumber';
    print('Current version: $currentVersionName');
    _getLatestReleaseInfo().then((value) {
      if (value != null) {
        String? latestVersionName = value['latestVersionName'];
        latestUpdateLog = value['latestUpdateLog'];
        print('Latest version: $latestVersionName');
        print('Update log: $latestUpdateLog');
        if (currentVersionName != latestVersionName) {
          updateUrl = value['updateUrl'] as String;
          apkName = value['apkName'] as String;
          _showUpdateDialog(false);
        } else {
          MyToast.showToast('Already the latest version');
        }
      }
    });
  }

  static _showUpdateDialog(bool forcedUpgrade) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: !forcedUpgrade,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return WillPopScope(
          onWillPop: () => Future.value(!forcedUpgrade),
          child: StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'New version available',
                style: textTheme.labelLarge,
              ),
              content: Text(
                latestUpdateLog!,
                style: textTheme.labelSmall,
              ),
              actions: <Widget>[
                if (!forcedUpgrade)
                  TextButton(
                      style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all(
                          colorScheme.primary,
                        ),
                        overlayColor: MaterialStateProperty.all(
                          Colors.grey,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: textTheme.labelMedium,
                      ),
                      onPressed: () {
                        if (isUpdateClicked) {
                          AzhonAppUpdate.cancel.then((value) {});
                          MyToast.showToast('Download canceled.');
                        }
                        Navigator.of(context).pop();
                      }),
                !isUpdateClicked
                    ? TextButton(
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all(
                            colorScheme.primary,
                          ),
                          overlayColor: MaterialStateProperty.all(
                            Colors.grey,
                          ),
                        ),
                        child: Text(
                          'Update',
                          style: textTheme.labelMedium,
                        ),
                        onPressed: () {
                          setState(() {
                            isUpdateClicked = !isUpdateClicked;
                          });
                          _appUpdate(setState);
                          // if (!forcedUpgrade) {
                          //   Navigator.of(context).pop();
                          // }
                        },
                      )
                    : TextButton(
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all(
                            colorScheme.primary,
                          ),
                          overlayColor: MaterialStateProperty.all(
                            Colors.grey,
                          ),
                        ),
                        child: Text(
                          '${(ratio * 100).toStringAsFixed(0)}%',
                          style: textTheme.labelMedium,
                        ),
                        onPressed: () {},
                      )
              ],
            );
          }),
        );
      },
    );
  }

  static _appUpdate(StateSetter setState) {
    // print('Update url: $updateUrl');
    UpdateModel model = UpdateModel(
      updateUrl,
      apkName,
      'ic_launcher',
      updateUrl,
    );
    AzhonAppUpdate.update(model).then((value) => print('$value'));
    AzhonAppUpdate.listener((map) {
      if (map['progress'] != null) {
        setState(() {
          ratio = map['progress'] / map['max'];
        });
        // print(ratio);
        // Navigator.of(navigatorKey.currentContext!).pop();
        // _showUpdateDialog(true);
      }
    });
  }

  static Future<Map<String, String>?> _getLatestReleaseInfo() async {
    final Uri url = Uri.parse(API.getLatestRelease);
    final client = RetryClient(http.Client());
    try {
      MyLogger.logger.i('Get latest release...');
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        String latestVersionName = decodedResponse['name'] as String;
        String latestUpdateLog = decodedResponse['body'] as String;
        String updateUrl = decodedResponse['assets'][0]['browser_download_url'];
        String apkName = decodedResponse['assets'][0]['name'];
        return {
          'latestVersionName': latestVersionName,
          'latestUpdateLog': latestUpdateLog,
          'updateUrl': updateUrl,
          'apkName': apkName,
        };
      } else {
        String errorMsg =
            'Response with code ${response.statusCode}: ${response.reasonPhrase}';
        MyToast.showToast(errorMsg);
        MyLogger.logger.e(errorMsg);
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
