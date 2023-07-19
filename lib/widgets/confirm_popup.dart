import 'package:flutter/material.dart';

class ShowConfirmDialog extends StatelessWidget {
  const ShowConfirmDialog(
      {super.key, required this.title, required this.onConfirm});
  final String title;
  final Function onConfirm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      content: Text(
        title,
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
            style: textTheme.labelSmall,
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
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(
            'Yes',
            style: textTheme.labelSmall!.copyWith(
              color: Color(0xFFFF0000),
            ),
          ),
        )
      ],
    );
  }
}
