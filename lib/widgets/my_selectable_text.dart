import 'dart:ui' as ui show BoxHeightStyle;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MySelectableText extends StatelessWidget {
  const MySelectableText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SelectableText(
      text,
      textAlign: textAlign,
      selectionHeightStyle: ui.BoxHeightStyle.max,
      contextMenuBuilder: (context, editableTextState) {
        final List<ContextMenuButtonItem> buttonItems =
            editableTextState.contextMenuButtonItems;
        return AdaptiveTextSelectionToolbar(
          anchors: editableTextState.contextMenuAnchors,
          children: [
            ...buttonItems.map<Widget>((buttonItem) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: buttonItem.onPressed,
                  child: Ink(
                    padding: EdgeInsets.all(8.0),
                    color: colorScheme.primary,
                    child: Text(
                      CupertinoTextSelectionToolbarButton.getButtonLabel(
                          context, buttonItem),
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList()
          ],
        );
      },
      style: style,
      maxLines: maxLines,
    );
  }
}
