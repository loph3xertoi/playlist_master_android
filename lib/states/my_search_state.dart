import 'package:flutter/material.dart';

class MySearchState extends ChangeNotifier {
  bool isSearching = false;
  updateSearchingState(bool isSearching) {
    this.isSearching = isSearching;
    notifyListeners();
  }
}
