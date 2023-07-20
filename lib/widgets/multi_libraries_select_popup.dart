import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import 'confirm_popup.dart';
import 'selectable_library_item.dart';

class MultiLibrariesSelectPopup extends StatefulWidget {
  const MultiLibrariesSelectPopup({super.key, required this.libraries});

  final List<BasicLibrary> libraries;

  @override
  State<MultiLibrariesSelectPopup> createState() =>
      _MultiLibrariesSelectPopupState();
}

class _MultiLibrariesSelectPopupState extends State<MultiLibrariesSelectPopup> {
  List<int> _selectedIndex = [];
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    int librariesCount = widget.libraries.length;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      child: Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _selectedIndex.isEmpty
                    ? 'Delete libraries'
                    : '${_selectedIndex.length} libraries selected',
                textAlign: TextAlign.center,
                style: textTheme.labelLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: librariesCount,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (_selectedIndex.contains(index)) {
                            _selectedIndex.remove(index);
                          } else {
                            _selectedIndex.add(index);
                          }
                        });
                      },
                      child: SelectableLibraryItem(
                        library: widget.libraries[index],
                        inMultiSelectMode: true,
                        isCreateLibraryItem: false,
                        selected: _selectedIndex.contains(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: _selectedIndex.isNotEmpty
                      ? () {
                          showDialog(
                            context: context,
                            builder: (_) => ShowConfirmDialog(
                              title: 'Do you want to remove these libraries?',
                              onConfirm: () {
                                _removeSelectedLibraries(appState);
                              },
                            ),
                          );
                        }
                      : null,
                  style: _selectedIndex.isNotEmpty
                      ? ButtonStyle(
                          shadowColor: MaterialStateProperty.all(
                            colorScheme.primary,
                          ),
                          overlayColor: MaterialStateProperty.all(
                            Colors.grey,
                          ),
                        )
                      : null,
                  child: Text(
                    'Remove',
                    style: _selectedIndex.isNotEmpty
                        ? textTheme.labelSmall
                        : textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSecondary.withOpacity(0.5),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _removeSelectedLibraries(MyAppState appState) async {
    List<BasicLibrary> removedLibraries =
        _selectedIndex.map((index) => widget.libraries[index]).toList();
    setState(() {
      _selectedIndex.clear();
    });

    var result;
    for (var library in removedLibraries) {
      var resultMap =
          await appState.deleteLibrary(library, appState.currentPlatform);
      if (resultMap != null && resultMap['result'] == 100) {
        result = 0;
      }
    }
    if (result == 0) {
      MyToast.showToast('Delete successfully');
    }
    appState.refreshLibraries!(appState, true);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
