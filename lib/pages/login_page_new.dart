import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../utils/mock_user.dart';
import '../widgets/login_widget/constants.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login_page';

  const LoginScreen({Key? key}) : super(key: key);

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<String?> _loginUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(data.name)) {
        return 'User not exists';
      }
      if (mockUsers[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  Future<String?> _resendCode(SignupData data) {
    return Future.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(data)) {
        return 'User not exists';
      }
      print(data);
      return null;
    });
  }

  Future<String?> _signupConfirm(String error, LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    return FlutterLogin(
      title: Constants.appName,
      logo: const AssetImage('assets/images/pm_round.png'),
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      navigateBackAfterRecovery: true,
      onConfirmRecover: _signupConfirm,
      onConfirmSignup: _signupConfirm,
      loginAfterSignUp: false,
      hideForgotPasswordButton: false,
      // showDebugButtons: true,
      loginProviders: [
        LoginProvider(
          button: Buttons.gitHub,
          label: 'Sign in with Github',
          callback: () async {
            return null;
          },
          providerNeedsSignUpCallback: () {
            // put here your logic to conditionally show the additional fields
            return Future.value(true);
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.google,
          callback: () async {
            return null;
          },
        ),
        // LoginProvider(
        //   icon: FontAwesomeIcons.github,
        //   callback: () async {
        //     debugPrint('start github sign in');
        //     await Future.delayed(loginTime);
        //     debugPrint('stop github sign in');
        //     return null;
        //   },
        // ),
      ],
      termsOfService: [
        TermOfService(
          id: 'newsletter',
          mandatory: false,
          text: 'Newsletter subscription',
        ),
        TermOfService(
          id: 'general-term',
          mandatory: true,
          text: 'Term of services',
          linkUrl: 'https://github.com/NearHuscarl/flutter_login',
        ),
      ],
      additionalSignupFields: [
        const UserFormField(
          keyName: 'Username',
          icon: Icon(FontAwesomeIcons.userLarge),
        ),
        UserFormField(
          keyName: 'phone_number',
          displayName: 'Phone Number',
          userType: LoginUserType.phone,
          fieldValidator: (value) {
            final phoneRegExp = RegExp(
              '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$',
            );
            if (value != null &&
                value.length < 7 &&
                !phoneRegExp.hasMatch(value)) {
              return "This isn't a valid phone number";
            }
            return null;
          },
        ),
      ],
      // scrollable: true,
      hideProvidersTitle: false,
      // loginAfterSignUp: false,
      // hideSignUpButton: true,
      disableCustomPageTransformer: true,
      messages: LoginMessages(
        userHint: 'User',
        passwordHint: 'Pass',
        confirmPasswordHint: 'Confirm',
        loginButton: 'LOG IN',
        signupButton: 'REGISTER',
        // forgotPasswordButton: 'Forgot huh?',
        recoverPasswordButton: 'RESET PASSWORD',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Not match!',
        recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
        recoverPasswordDescription:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
        recoverPasswordSuccess: 'Password rescued successfully',
        flushbarTitleError: 'Oh no!',
        flushbarTitleSuccess: 'Success!',
        // providersTitle: 'login with'),
      ),
      theme: LoginTheme(
        primaryColor: Colors.teal,
        accentColor: Colors.yellow,
        // errorColor: Colors.deepOrange,
        pageColorLight: Colors.indigo.shade300,
        // pageColorDark: Colors.indigo.shade500,
        logoWidth: 0.80,
        titleStyle: TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'Quicksand',
          letterSpacing: 4,
        ),
        beforeHeroFontSize: 40,
        afterHeroFontSize: 20,
        bodyStyle: textTheme.labelSmall!.copyWith(color: Colors.black),
        // textFieldStyle: TextStyle(
        //   color: Colors.orange,
        //   shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
        // ),
        textFieldStyle: textTheme.labelLarge!.copyWith(color: Colors.black),
        buttonStyle: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.yellow,
        ),
        cardTheme: CardTheme(
          color: colorScheme.primary == Colors.white
              ? Colors.yellow.shade100
              : Colors.purple.shade100,
          elevation: 5,
          margin: EdgeInsets.only(top: 0),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.purple.withOpacity(.1),
          contentPadding: EdgeInsets.zero,
          errorStyle: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          labelStyle: textTheme.labelMedium!.copyWith(color: Colors.black),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
            // borderRadius: inputBorder,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
            // borderRadius: inputBorder,
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 7),
            // borderRadius: inputBorder,
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade400, width: 8),
            // borderRadius: inputBorder,
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 5),
            // borderRadius: inputBorder,
          ),
        ),
        // buttonTheme: LoginButtonTheme(
        //   splashColor: Colors.blue,
        //   // backgroundColor: Colors.pinkAccent,
        //   // highlightColor: Colors.lightGreen,
        //   elevation: 1.0,
        //   highlightElevation: 4.0,
        //   // shape: BeveledRectangleBorder(
        //   //   borderRadius: BorderRadius.circular(10),
        //   // ),
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        //   // shape: CircleBorder(side: BorderSide(color: Colors.green)),
        //   // shape: ContinuousRectangleBorder(
        //   //     borderRadius: BorderRadius.circular(55.0)),
        // ),
      ),
      userValidator: (value) {
        if (!value!.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        debugPrint('Login info');
        debugPrint('Name: ${loginData.name}');
        debugPrint('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        debugPrint('Signup info');
        debugPrint('Name: ${signupData.name}');
        debugPrint('Password: ${signupData.password}');

        signupData.additionalSignupData?.forEach((key, value) {
          debugPrint('$key: $value');
        });
        if (signupData.termsOfService.isNotEmpty) {
          debugPrint('Terms of service: ');
          for (final element in signupData.termsOfService) {
            debugPrint(
              ' - ${element.term.id}: ${element.accepted == true ? 'accepted' : 'rejected'}',
            );
          }
        }
        return _signupUser(signupData);
      },
      onSubmitAnimationCompleted: () {
        // Navigator.of(context).pushReplacement(
        //   FadePageRoute(
        //     builder: (context) => const DashboardScreen(),
        //   ),
        // );
        Navigator.of(context).pushReplacementNamed('/home_page');
      },
      onResendCode: _resendCode,
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      headerWidget: const IntroWidget(),
    );
  }
}

class IntroWidget extends StatelessWidget {
  const IntroWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Welcome to Playlist Master, please login or sign up first.'),
        Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Authenticate',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}
