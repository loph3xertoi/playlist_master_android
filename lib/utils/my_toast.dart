import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';

class MyToast {
  static void showToast(String msg) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _showToastInAndroidOrIOS(msg);
    } else {
      _showToastInWebOrLinux(msg);
    }
  }

  static void _showToastInAndroidOrIOS(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Color(0xFF302F32),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void _showToastInWebOrLinux(String msg) {
    var fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Color(0xFF302F32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/pm_round.png', height: 20.0, width: 20.0),
          SizedBox(width: 12.0),
          Text(msg, style: TextStyle(fontSize: 16.0, color: Colors.white))
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

    // Custom Toast Position
    // fToast.showToast(
    //     child: toast,
    //     toastDuration: Duration(seconds: 2),
    //     positionedToastBuilder: (context, child) {
    //       return Positioned(
    //         top: 16.0,
    //         left: 16.0,
    //         child: child,
    //       );
    //     });
  }
}
