import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  bool isShowBottomPlayer = true;

  get getIsShowBottomPlayer => isShowBottomPlayer;

  void setIsShowBottomPlayer(bool value) {
    isShowBottomPlayer = value;
    notifyListeners();
  }
}
