import 'package:flutter/material.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:provider/provider.dart';

class ShowConfirmDialog extends StatelessWidget {
  const ShowConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    return AlertDialog(
      // title: Text('Are you sure?'),
      content: Text('Do you want to empty the queue?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        TextButton(
          onPressed: () {
            appState.queue = [];
            Navigator.pop(context);
          },
          child: Text(
            'Yes',
            style: TextStyle(color: Color(0xFFFF0000)),
          ),
        )
      ],
    );
  }
}
