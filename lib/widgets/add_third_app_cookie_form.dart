// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:playlistmaster/widgets/confirm_popup.dart';
import 'package:provider/provider.dart';

import '../config/user_info.dart';
import '../states/app_state.dart';

class AddThirdAppCookieForm extends StatefulWidget {
  /// Third app's type, 1 for qqmusic, 2 for ncm, 3 for bilibili.
  final int thirdAppType;

  const AddThirdAppCookieForm({super.key, required this.thirdAppType});

  @override
  State<AddThirdAppCookieForm> createState() => _AddThirdAppCookieFormState();
}

class _AddThirdAppCookieFormState extends State<AddThirdAppCookieForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, top: 20.0, right: 40.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'third_app_id',
              decoration: InputDecoration(
                labelText: 'Id',
                labelStyle: textTheme.labelSmall,
                // enabledBorder: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
              ),
              initialValue: widget.thirdAppType == 1
                  ? UserInfo.basicUser!.qqMusicId
                  : widget.thirdAppType == 2
                      ? UserInfo.basicUser!.ncmId
                      : widget.thirdAppType == 3
                          ? UserInfo.basicUser!.biliId
                          : null,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.maxLength(50),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              name: 'third_app_cookie',
              decoration: InputDecoration(
                labelText: 'Cookie',
                labelStyle: textTheme.labelSmall,
                // enabledBorder: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
              ),
              initialValue: widget.thirdAppType == 1
                  ? UserInfo.basicUser!.qqMusicCookie
                  : widget.thirdAppType == 2
                      ? UserInfo.basicUser!.ncmCookie
                      : widget.thirdAppType == 3
                          ? UserInfo.basicUser!.biliCookie
                          : null,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(
                    colorScheme.primary,
                  ),
                  overlayColor: MaterialStateProperty.all(
                    Colors.grey,
                  ),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ))),
              onPressed: () {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return ShowConfirmDialog(
                          title: 'Do you want to add third app\'s credential?',
                          onConfirm: () async {
                            var value = _formKey.currentState?.value;
                            var id = value?['third_app_id'];
                            var cookie = value?['third_app_cookie'];
                            var success = await appState.updateCredential(
                                id, cookie, widget.thirdAppType);
                            if (mounted && success) {
                              if (widget.thirdAppType == 1) {
                                UserInfo.basicUser!.qqMusicId = id;
                                UserInfo.basicUser!.qqMusicCookie = cookie;
                              } else if (widget.thirdAppType == 2) {
                                UserInfo.basicUser!.ncmId = id;
                                UserInfo.basicUser!.ncmCookie = cookie;
                              } else if (widget.thirdAppType == 3) {
                                UserInfo.basicUser!.biliId = id;
                                UserInfo.basicUser!.biliCookie = cookie;
                              } else {
                                throw 'Invalid third app type';
                              }
                              Navigator.pop(context, success);
                            }
                          },
                        );
                      });
                }
              },
              child: Text('Submit', style: textTheme.labelMedium),
            ),
          ],
        ),
      ),
    );
  }
}
