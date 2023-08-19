import 'package:flutter/material.dart';
import 'package:playlistmaster/widgets/foldable_text_widget.dart';

class FoldableResourceIntroWidget extends StatefulWidget {
  final String title;
  final Widget subTitle;
  final Widget content;
  final bool isExpanded;

  const FoldableResourceIntroWidget({
    required this.title,
    required this.subTitle,
    required this.content,
    this.isExpanded = false,
  });

  @override
  State<FoldableResourceIntroWidget> createState() =>
      _FoldableTextWidgetState();
}

class _FoldableTextWidgetState extends State<FoldableResourceIntroWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    // TODO: fix bug: the shadow box of sub resources bar will shift
                    // when expand the detail resource intro.
                    onTap: () {
                      if (!widget.isExpanded) {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5.0, bottom: 2.0),
                      child: FoldableTextWidget(
                        widget.title,
                        style: textTheme.labelMedium,
                        isExpanded: isExpanded,
                      ),
                    ),
                  ),
                ),
                widget.subTitle,
                isExpanded ? widget.content : Container(),
              ],
            );
          },
        ),
      ],
    );
  }
}
