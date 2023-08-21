import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomColorSelectionHandle extends TextSelectionControls {
  CustomColorSelectionHandle(this.handleColor)
      : _controls = materialTextSelectionControls;

  final Color handleColor;
  final TextSelectionControls _controls;

  /// Wrap the given handle builder with the needed theme data for
  /// each platform to modify the color.
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) =>
      TextSelectionTheme(
          data: TextSelectionThemeData(selectionHandleColor: handleColor),
          child: Builder(builder: builder));

  @override
  Widget buildHandle(
      BuildContext context, TextSelectionHandleType type, double textLineHeight,
      [VoidCallback? onTap]) {
    return _wrapWithThemeData((BuildContext context) =>
        _controls.buildHandle(context, type, textLineHeight));
  }

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset selectionMidpoint,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus,
      Offset? lastSecondaryTapDownPosition) {
    return _controls.buildToolbar(
        context,
        globalEditableRegion,
        textLineHeight,
        selectionMidpoint,
        endpoints,
        delegate,
        clipboardStatus,
        lastSecondaryTapDownPosition);
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return _controls.getHandleAnchor(type, textLineHeight);
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return _controls.getHandleSize(textLineHeight);
  }
}
