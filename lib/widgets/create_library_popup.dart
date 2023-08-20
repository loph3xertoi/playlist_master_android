// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui' as ui show BoxHeightStyle;

import 'package:flutter/material.dart';
import 'package:playlistmaster/widgets/custom_selection_handler.dart';
import 'package:provider/provider.dart';

import '../entities/dto/result.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';

class CreateLibraryDialog extends StatefulWidget {
  CreateLibraryDialog({
    Key? key,
    this.initText,
  }) : super(key: key);

  final String? initText;

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
    if (value == '') {
      MyToast.showToast('Please enter library name!');
    } else {
      Future<Result?> result =
          appState.createLibrary(value, appState.currentPlatform);
      if (mounted) {
        Navigator.pop(context, result);
      }
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
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
                child: Theme(
                  data: currentPlatform == 3
                      ? Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: Color(0xFFBB5A7D),
                            selectionColor: Color(0xFFB75674),
                            selectionHandleColor: Color(0xFFEC6F92),
                          ),
                        )
                      : Theme.of(context),
                  child: TextField(
                    selectionControls: currentPlatform == 3
                        ? CustomColorSelectionHandle(Color(0xFFEC6F92))
                        : null,
                    controller: _textEditingController,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    style: textTheme.titleMedium!.copyWith(
                      color: colorScheme.onSecondary,
                    ),
                    selectionHeightStyle: ui.BoxHeightStyle.max,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      hintText: 'New Library',
                      hintStyle: textTheme.titleMedium,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 10.0),
                      suffixIcon: _showSuffixIcon
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
            ),
          ],
        ),
      ),
    );
  }
}
