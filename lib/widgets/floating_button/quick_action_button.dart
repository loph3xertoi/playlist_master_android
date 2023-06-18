import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../states/my_navigation_button_state.dart';
import 'quick_action.dart';
import 'quick_action_icon.dart';

class QuickActionButton extends StatefulWidget {
  final QuickAction action;
  final bool isOpen;
  final int index;
  final Function() close;

  const QuickActionButton(
    this.action, {
    super.key,
    required this.isOpen,
    required this.index,
    required this.close,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  final _radius = 80.0;
  final _offset = 50.0;

  double degToRad(double deg) {
    return pi * deg / 180.0;
  }

  double get _range => 180.0 - _offset;

  double get _alpha => _offset / 2 + widget.index * _range / 2;

  double get _radian => degToRad(_alpha);

  double get _b => sin(_radian) * _radius;

  double get _a => cos(_radian) * _radius;

  double get _rotateDeg => widget.index / 10 - 0.1;

  final _duration = const Duration(milliseconds: 250);
  var _isPressed = false;
  var _isClicked = false;

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

  _onTap() {
    widget.close();
    widget.action.onTap();
  }

  @override
  Widget build(BuildContext context) {
    var myNavigationButtonState = context.watch<MyNavigationButtonState>();
    var selected = myNavigationButtonState.selected;
    var clicked = myNavigationButtonState.clicked;
    var dragged = myNavigationButtonState.dragged;
    var iconsPosition = myNavigationButtonState.popupIconsPosition;
    if (dragged) {
      if (selected == widget.index) {
        _isPressed = true;
      } else {
        _isPressed = false;
      }
    }
    if (clicked == widget.index) {
      _isClicked = true;
      _isPressed = false;
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseRightOffset = (screenWidth - 92.0) / 2;
    // print('button ${widget.index} x: ${baseRightOffset + 46 + _a}');
    // print('button ${widget.index} y: ${screenHeight - _b - 46}');
    iconsPosition[widget.index] =
        (baseRightOffset + 46.0 + _a, screenHeight - _b - 46.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isClicked) {
        _isClicked = false;
        _onTap();
        myNavigationButtonState.changeClicked(-1);
      }
    });

    return AnimatedPositioned(
      duration: _duration,
      bottom: widget.isOpen ? _b : 0,
      right: widget.isOpen ? baseRightOffset - _a : baseRightOffset,
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.all(16.0)
            .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
        child: AnimatedRotation(
          turns: widget.isOpen ? 0 : _rotateDeg,
          alignment: Alignment.center,
          curve: Curves.easeOut,
          duration: _duration * 1.5,
          child: AnimatedOpacity(
            opacity: widget.isOpen ? 1 : 0,
            duration: _duration,
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : 1,
              duration: _duration,
              child: GestureDetector(
                onTapDown: (_) => _pressDown(),
                onTapUp: (_) => _pressUp(),
                onTapCancel: () => _pressUp(),
                onTap: _onTap,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2,
                        offset: Offset(0, 2),
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: QuickActionIcon(
                    imageUri: widget.action.imageUri,
                    backgroundColor: widget.action.backgroundColor,
                    width: 60.0,
                    height: 60.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
