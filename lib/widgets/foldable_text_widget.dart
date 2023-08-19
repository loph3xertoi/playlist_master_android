import 'package:flutter/material.dart';

class FoldableTextWidget extends StatefulWidget {
  final String text;
  final bool isExpanded;
  final TextStyle? style;

  const FoldableTextWidget(
    this.text, {
    this.isExpanded = false,
    this.style,
  });

  @override
  State<FoldableTextWidget> createState() => _FoldableTextWidgetState();
}

class _FoldableTextWidgetState extends State<FoldableTextWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
          child: Text(
            widget.text,
            softWrap: true,
            overflow: widget.isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            maxLines: widget.isExpanded ? null : 1,
          ),
        )),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
          child: !widget.isExpanded
              ? Icon(Icons.expand_more_rounded,
                  color: colorScheme.onPrimary.withOpacity(0.5))
              : Icon(Icons.expand_less_rounded,
                  color: colorScheme.onPrimary.withOpacity(0.5)),
        ),
      ],
    );
  }
}
