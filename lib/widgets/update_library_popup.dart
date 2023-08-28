// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/basic/basic_library.dart';
import 'package:playlistmaster/entities/dto/updated_library_dto.dart';
import 'package:playlistmaster/entities/pms/pms_detail_library.dart';
import 'package:playlistmaster/widgets/my_selectable_text.dart';
import 'package:provider/provider.dart';

import '../entities/dto/result.dart';
import '../states/app_state.dart';

class UpdateLibraryDialog extends StatefulWidget {
  UpdateLibraryDialog({
    Key? key,
    required this.library,
  }) : super(key: key);

  final BasicLibrary library;

  @override
  State<UpdateLibraryDialog> createState() => _UpdateLibraryDialogState();
}

class _UpdateLibraryDialogState extends State<UpdateLibraryDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  late Future<BasicLibrary?> _detailLibrary;

  int? _libraryId;

  XFile? _formerCover;

  void _onCancelPressed(BuildContext context) {
    _removeCachedFormImage();
    Navigator.pop(context);
  }

  void _onSubmitted(BuildContext context, MyAppState appState) async {
    // Validate and save the form values
    _formKey.currentState?.saveAndValidate();
    var newLibrary = _formKey.currentState?.value;
    String name = newLibrary!['name'];
    String intro = newLibrary['intro'];
    var coverList = newLibrary['cover'];
    XFile? cover;
    http.MultipartFile? multipartFile;
    if (coverList != null) {
      cover = coverList[0];
      multipartFile = await http.MultipartFile.fromPath(
        'cover',
        cover!.path,
        filename: cover.name,
        contentType: MediaType('image', 'jpeg'),
      );
    }
    UpdatedLibraryDTO updatedLibrary =
        UpdatedLibraryDTO(_libraryId!, name, intro, multipartFile);

    Future<Result?> result = appState.updateLibrary(
      updatedLibrary,
      appState.currentPlatform,
    );
    // await MyHttp.myImageCacheManager.removeFile(widget.library.cover);
    // await MyHttp.clearCache();
    Timer(Duration(seconds: 3), () {
      _removeCachedFormImage();
    });
    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  void _removeCachedFormImage() {
    if (_formerCover != null) {
      File file = File(_formerCover!.path);
      Directory cacheDirectory = file.parent;
      if (file.existsSync()) {
        file.deleteSync();
        cacheDirectory.deleteSync();
      } else {
        print('Cover to delete does not exist');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _detailLibrary =
        state.fetchDetailLibrary(widget.library, state.currentPlatform);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    return WillPopScope(
      onWillPop: () async {
        _removeCachedFormImage();
        return true;
      },
      child: Dialog(
        // backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(0.0),
        alignment: Alignment.bottomCenter,
        child: FutureBuilder(
            future: _detailLibrary,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MySelectableText(
                        snapshot.hasError
                            ? '${snapshot.error}'
                            : appState.errorMsg,
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      TextButton.icon(
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all(
                            colorScheme.primary,
                          ),
                          overlayColor: MaterialStateProperty.all(
                            Colors.grey,
                          ),
                        ),
                        icon: Icon(
                          MdiIcons.webRefresh,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Retry',
                          style: textTheme.labelMedium!.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _detailLibrary = appState.fetchDetailLibrary(
                                widget.library, currentPlatform);
                          });
                        },
                      ),
                    ],
                  ),
                );
              } else {
                final library = snapshot.data as PMSDetailLibrary;
                _libraryId = library.id;
                return Material(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  child: SizedBox(
                    // width: 300.0,
                    height: 600.0,
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
                                'Update library',
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
                                _onSubmitted(context, appState);
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
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: FormBuilder(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FormBuilderImagePicker(
                                  name: 'cover',
                                  maxImages: 1,
                                  placeholderImage: NetworkImage(library.cover),
                                  // placeholderImage: CachedNetworkImageProvider(
                                  //   library.cover,
                                  //   cacheManager: MyHttp.myImageCacheManager,
                                  // ),
                                  fit: BoxFit.cover,
                                  decoration: InputDecoration(
                                      labelText: 'Cover',
                                      labelStyle: textTheme.labelSmall),
                                  transformImageWidget:
                                      (context, displayImage) => Align(
                                    alignment: Alignment.center,
                                    child: displayImage,
                                  ),
                                  onChanged: (value) {
                                    if (value!.isNotEmpty) {
                                      _formerCover = value[0];
                                    } else {
                                      _removeCachedFormImage();
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                FormBuilderTextField(
                                  name: 'name',
                                  initialValue: library.name,
                                  decoration: InputDecoration(
                                      labelText: 'Name',
                                      labelStyle: textTheme.labelSmall),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                  ]),
                                  onChanged: (value) {
                                    _formKey.currentState?.validate();
                                  },
                                  onSubmitted: (value) {
                                    _onSubmitted(context, appState);
                                  },
                                ),
                                const SizedBox(height: 10),
                                FormBuilderTextField(
                                  name: 'intro',
                                  initialValue: library.intro,
                                  decoration: InputDecoration(
                                      labelText: 'Intro',
                                      labelStyle: textTheme.labelSmall),
                                  onChanged: (val) {
                                    _formKey.currentState?.validate();
                                  },
                                  onSubmitted: (value) {
                                    _onSubmitted(context, appState);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }
}
