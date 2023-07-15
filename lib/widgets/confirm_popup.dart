import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class ShowConfirmDialog extends StatelessWidget {
  const ShowConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      content: Text(
        'Do you want to empty the queue?',
        style: textTheme.labelMedium,
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(
              colorScheme.primary,
            ),
            overlayColor: MaterialStateProperty.all(
              Colors.grey,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: textTheme.labelMedium,
          ),
        ),
        TextButton(
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(
              colorScheme.primary,
            ),
            overlayColor: MaterialStateProperty.all(
              Colors.grey,
            ),
          ),
          onPressed: () {
            appState.queue = [];
            Navigator.of(context).pop();
          },
          child: Text(
            'Yes',
            style: textTheme.labelMedium!.copyWith(
              color: Color(0xFFFF0000),
            ),
          ),
        )
      ],
    );
  }
}
