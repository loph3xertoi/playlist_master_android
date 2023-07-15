import 'package:flutter/material.dart';

class CreatePlaylistDialog extends StatelessWidget {
  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFinishPressed(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      // backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      child: Material(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: ButtonStyle(
                    shadowColor: MaterialStateProperty.all(
                      colorScheme.primary,
                    ),
                    overlayColor: MaterialStateProperty.all(
                      Colors.grey,
                    ),
                  ),
                  onPressed: () => _onCancelPressed(context),
                  child: Text(
                    'Cancel',
                    style: textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Add new library:',
                    textAlign: TextAlign.center,
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
                    _onFinishPressed(context);
                  },
                  child: Text(
                    'Finish',
                    style: textTheme.labelSmall!.copyWith(
                      color: Color(0xFF0066FF),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 15.0),
              child: Container(
                height: 32.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: colorScheme.secondary,
                ),
                child: TextField(
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: colorScheme.onPrimary,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    hintText: 'New Library',
                    hintStyle: textTheme.titleMedium,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                    suffixIcon: Icon(Icons.cancel_rounded),
                    suffixIconColor: colorScheme.tertiary,
                    border: InputBorder.none,
                  ),
                  onTap: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
