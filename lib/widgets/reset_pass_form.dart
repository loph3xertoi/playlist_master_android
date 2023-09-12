// ignore_for_file: unnecessary_string_escapes

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _newPassObscureText = true;
  bool _confirmPassObscureText = true;
  var _disableResendButton = false;
  var _counter = 0;
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
                      name: 'new_password',
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: textTheme.labelSmall,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      obscureText: _newPassObscureText,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(8),
                        FormBuilderValidators.maxLength(16),
                        // FormBuilderValidators.match(
                        //     '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\(\)\{\}\[\]!@#\$%^&\*])(?=.{8,})'),
                      ]),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _newPassObscureText = !_newPassObscureText;
                      });
                    },
                    icon: _newPassObscureText
                        ? Icon(MdiIcons.eyeOff)
                        : Icon(MdiIcons.eye),
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'confirm_password',
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: textTheme.labelSmall,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      obscureText: _confirmPassObscureText,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => _formKey.currentState
                                  ?.fields['new_password']?.value !=
                              value
                          ? 'No coinciden'
                          : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _confirmPassObscureText = !_confirmPassObscureText;
                      });
                    },
                    icon: _confirmPassObscureText
                        ? Icon(MdiIcons.eyeOff)
                        : Icon(MdiIcons.eye),
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                            _triggerCounter(60);
                            var success = await appState.forgotPassword();
                            if (success) {
                              MyToast.showToast(
                                  'The verified code has been sent to your email');
                            }
                          },
                          child:
                              Text('Send code', style: textTheme.labelMedium),
                        ),
                ],
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
                onPressed: () async {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    var value = _formKey.currentState?.value;
                    var password = value?['new_password'];
                    var repeatedPassword = value?['confirm_password'];
                    var token = value?['verified_code'];
                    var success = await appState.verifyResetPassToken(
                        password, repeatedPassword, token);
                    if (!success) {
                      MyToast.showToast(appState.errorMsg);
                    } else {
                      MyToast.showToast('Reset password successfully');
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
