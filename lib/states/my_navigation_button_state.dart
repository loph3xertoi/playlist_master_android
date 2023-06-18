import 'package:flutter/material.dart';

class MyNavigationButtonState extends ChangeNotifier {
  // -1 represents no popup icon is selected, 0 for the right, 1 for middle, 2 for the left.
  int selected = -1;
  // true represents the popup icon is selected and clicked.
  int clicked = -1;
  // true represents the navigation button is dragged.
  bool dragged = false;

  List<(double, double)> popupIconsPosition = List.filled(3, (0.0, 0.0));

  void changeSelected(int selected) {
    this.selected = selected;
    notifyListeners();
  }

  void updateDraggedState(bool dragged) {
    this.dragged = dragged;
    notifyListeners();
  }

  void changeClicked(int clicked) {
    this.clicked = clicked;
    notifyListeners();
  }
}
