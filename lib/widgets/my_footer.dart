import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class MyFooter extends StatefulWidget {
  @override
  State<MyFooter> createState() => _MyFooterState();
}

class _MyFooterState extends State<MyFooter> {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      height: 70.0,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        border: Border.all(
          width: 0,
          color: colorScheme.primary,
        ),
        boxShadow: [
          appState.isQueueEmpty
              ? BoxShadow(
                  color: Colors.transparent.withOpacity(0.2),
                  spreadRadius: 0.0,
                  blurRadius: 4.0,
                  offset: Offset(0.0, 0.0), // changes position of shadow
                )
              : BoxShadow(),
        ],
      ),
    );
  }
}
