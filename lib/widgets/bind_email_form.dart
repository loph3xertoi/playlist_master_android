// ignore_for_file: unnecessary_string_escapes

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:playlistmaster/config/user_info.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class BindEmailForm extends StatefulWidget {
  const BindEmailForm({Key? key}) : super(key: key);

  @override
  State<BindEmailForm> createState() => _BindEmailFormState();
}

class _BindEmailFormState extends State<BindEmailForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailKey = GlobalKey<FormBuilderFieldState>();
  var _disableResendButton = false;
  var _counter = 0;
  var _changeEmail = UserInfo.basicUser?.email == null;
  Timer? _timer;

  void _triggerCounter(int resendCodeInterval) {
    setState(() {
      _disableResendButton = true;
      _counter = resendCodeInterval;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_counter > 0) {
            _counter--;
          } else {
            _disableResendButton = false;
            timer.cancel();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var email = UserInfo.basicUser?.email;
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 10.0),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      key: _emailKey,
                      name: 'email',
                      readOnly: !_changeEmail,
                      initialValue: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: textTheme.labelSmall,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(
                            errorText: 'Please enter a valid email'),
                      ]),
                    ),
                  ),
                  if (!_changeEmail)
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
                        setState(() {
                          _changeEmail = !_changeEmail;
                        });
                      },
                      child: Text('Change', style: textTheme.labelSmall),
                    ),
                ],
              ),
              if (_changeEmail) const SizedBox(height: 10),
              if (_changeEmail)
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'verified_code',
                        decoration: InputDecoration(
                          labelText: 'Verified Code',
                          labelStyle: textTheme.labelSmall,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.equalLength(8),
                        ]),
                      ),
                    ),
                    _disableResendButton
                        ? SizedBox(
                            width: 84.0,
                            child: Center(
                              child: Text(
                                '${_counter}s',
                                style: textTheme.labelSmall!
                                    .copyWith(color: Colors.grey),
                              ),
                            ),
                          )
                        : TextButton(
                            style: ButtonStyle(
                              shadowColor: MaterialStateProperty.all(
                                colorScheme.primary,
                              ),
                              overlayColor: MaterialStateProperty.all(
                                Colors.grey,
                              ),
                            ),
                            onPressed: () async {
                              if (_emailKey.currentState?.validate() ?? false) {
                                var email = _emailKey.currentState?.value;
                                _triggerCounter(60);
                                var success = await appState.bindEmail(email);
                                if (success) {
                                  MyToast.showToast(
                                      'The verified code has been sent to your email');
                                } else {
                                  MyToast.showToast(appState.errorMsg);
                                }
                              }
                            },
                            child:
                                Text('Send code', style: textTheme.labelMedium),
                          ),
                  ],
                ),
              if (_changeEmail) const SizedBox(height: 10),
              if (_changeEmail)
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
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      var value = _formKey.currentState?.value;
                      var email = value?['email'];
                      var token = value?['verified_code'];
                      var success =
                          await appState.verifyBindEmailToken(email, token);
                      if (!success) {
                        MyToast.showToast(appState.errorMsg);
                      } else {
                        setState(() {
                          _changeEmail = false;
                          UserInfo.basicUser?.email = email;
                        });
                        MyToast.showToast('Bind email successfully');
                      }
                    }
                  },
                  child: Text('Submit', style: textTheme.labelMedium),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
