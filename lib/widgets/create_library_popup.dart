// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../utils/my_toast.dart';

class CreateLibraryDialog extends StatefulWidget {
  CreateLibraryDialog({
    Key? key,
    this.initText,
  }) : super(key: key);

  String? initText;

  @override
  State<CreateLibraryDialog> createState() => _CreateLibraryDialogState();
}

class _CreateLibraryDialogState extends State<CreateLibraryDialog> {
  late TextEditingController _textEditingController;
  bool _showSuffixIcon = false;

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFinishPressed(BuildContext context, MyAppState appState) {
    _onSubmitted(context, _textEditingController.text, appState);
  }

  void _onSubmitted(
      BuildContext context, String value, MyAppState appState) async {
    int libraryId = -1;
    if (value == '') {
      MyToast.showToast('Please enter library name!');
    } else {
      int? result =
          await appState.createLibrary(value, appState.currentPlatform);
      if (result != null) {
        MyToast.showToast('Create new library successfully!');
        libraryId = result;
        appState.refreshLibraries!(appState, true);
      } else {
        MyToast.showToast('Create library failed!');
      }
    }
    if (mounted) {
      Navigator.pop(context, libraryId);
    }
  }

  void _updateSuffixIconVisibility() {
    setState(() {
      _showSuffixIcon = _textEditingController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_updateSuffixIconVisibility);
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    if (widget.initText != null) {
      _textEditingController.text = widget.initText!;
    }
    _textEditingController.addListener(_updateSuffixIconVisibility);
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
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
                    _onFinishPressed(context, appState);
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
              padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 40.0),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: colorScheme.secondary,
                ),
                child: TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: colorScheme.onPrimary,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSecondary,
                  ),
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    hintText: 'New Library',
                    hintStyle: textTheme.titleMedium,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                    suffixIcon: _textEditingController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _textEditingController.clear(),
                            child: Icon(Icons.cancel_rounded))
                        : null,
                    suffixIconColor: colorScheme.tertiary,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    _onSubmitted(context, value, appState);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
