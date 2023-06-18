import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../states/my_navigation_button_state.dart';
import 'quick_action_icon.dart';
import 'dart:math';

class QuickActionMenuFloatingActionButton extends StatefulWidget {
  final Function() open;
  final Function() close;
  final Function() onTap;
  final bool isOpen;
  final String imageUri;
  final Color backgroundColor;

  const QuickActionMenuFloatingActionButton({
    required this.open,
    required this.close,
    required this.onTap,
    required this.isOpen,
    required this.imageUri,
    required this.backgroundColor,
    super.key,
  });

  @override
  State<QuickActionMenuFloatingActionButton> createState() =>
      _QuickActionMenuFloatingActionButtonState();
}

class _QuickActionMenuFloatingActionButtonState
    extends State<QuickActionMenuFloatingActionButton> {
  final _duration = const Duration(milliseconds: 200);
  var _isPressed = false;
  int _selectedIcons = -1;

  _pressDown() {
    setState(() {
      _isPressed = true;
    });
  }

  _pressUp() {
    setState(() {
      _isPressed = false;
    });
  }

  _onLongPressEnd(MyNavigationButtonState myNavigationButtonState) {
    myNavigationButtonState.updateDraggedState(false);
    if (_selectedIcons == 0) {
      myNavigationButtonState.changeClicked(0);
    } else if (_selectedIcons == 1) {
      myNavigationButtonState.changeClicked(1);
    } else if (_selectedIcons == 2) {
      myNavigationButtonState.changeClicked(2);
    } else {
      myNavigationButtonState.changeClicked(-1);
    }
    _selectedIcons = -1;
    myNavigationButtonState.changeSelected(-1);
  }

  _onLongPressMoveUpdate(LongPressMoveUpdateDetails details,
      MyNavigationButtonState myNavigationButtonState) {
    if (!myNavigationButtonState.dragged) {
      myNavigationButtonState.updateDraggedState(true);
    }
    int currentSelectedIcon =
        _currentSelectedIcon(myNavigationButtonState, details.globalPosition);
    _selectedIcons = currentSelectedIcon;
    if (currentSelectedIcon != myNavigationButtonState.selected) {
      myNavigationButtonState.changeSelected(currentSelectedIcon);
    }
  }

  int _currentSelectedIcon(
      MyNavigationButtonState myNavigationButtonState, Offset currentPoint) {
    var iconsPosition = myNavigationButtonState.popupIconsPosition;
    Offset coordinate0 = Offset(iconsPosition[0].$1, iconsPosition[0].$2);
    Offset coordinate1 = Offset(iconsPosition[1].$1, iconsPosition[1].$2);
    Offset coordinate2 = Offset(iconsPosition[2].$1, iconsPosition[2].$2);
    double distance0 = _distance(currentPoint, coordinate0);
    double distance1 = _distance(currentPoint, coordinate1);
    double distance2 = _distance(currentPoint, coordinate2);
    return (distance0 < 30)
        ? 0
        : (distance1 < 30)
            ? 1
            : (distance2 < 30)
                ? 2
                : -1;
  }

  double _distance(Offset a, Offset b) {
    return sqrt((a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy));
  }

  @override
  Widget build(BuildContext context) {
    var myNavigationButtonState = context.watch<MyNavigationButtonState>();
    return GestureDetector(
      onTapDown: (_) => _pressDown(),
      onTapUp: (_) => _pressUp(),
      onTapCancel: () => _pressUp(),
      onTap: () => widget.isOpen ? widget.close() : widget.onTap(),
      onLongPressMoveUpdate: (details) =>
          _onLongPressMoveUpdate(details, myNavigationButtonState),
      onLongPress: () {
        if (!widget.isOpen) {
          widget.open();
          _pressUp();
        }
      },
      onLongPressEnd: (details) => _onLongPressEnd(myNavigationButtonState),
      child: AnimatedScale(
        scale: _isPressed || widget.isOpen ? 0.8 : 1,
        duration: _duration,
        child: Stack(
          children: [
            QuickActionIcon(
              imageUri: widget.imageUri,
              backgroundColor: widget.backgroundColor,
              width: 50.0,
              height: 50.0,
            ),
            AnimatedOpacity(
              opacity: widget.isOpen ? 0 : 1,
              duration: _duration,
              child: QuickActionIcon(
                imageUri: widget.imageUri,
                backgroundColor: widget.backgroundColor,
                width: 50.0,
                height: 50.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
