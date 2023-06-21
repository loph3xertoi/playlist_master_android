import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  bool _isQueueEmpty = true;

  bool get isQueueEmpty => _isQueueEmpty;

  void toggleBottomPlayer() {
    _isQueueEmpty = !_isQueueEmpty;
    notifyListeners();
  }
}
