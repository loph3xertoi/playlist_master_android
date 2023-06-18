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
    return Dialog(
      backgroundColor: Colors.white,
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
                  onPressed: () => _onCancelPressed(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.0,
                      letterSpacing: 0.1,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Add new playlist:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _onFinishPressed(context);
                  },
                  child: Text(
                    'Finish',
                    style: TextStyle(
                      fontSize: 14.0,
                      letterSpacing: 0.1,
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
                  color: Color(0x0D000000),
                ),
                child: TextField(
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    hintText: 'New Playlist',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 9.0, horizontal: 10.0),
                    suffixIcon: Icon(Icons.cancel_rounded),
                    suffixIconColor: Color(0xFFC2CADC),
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
