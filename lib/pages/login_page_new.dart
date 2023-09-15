import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../states/app_state.dart';
import '../utils/oauth2_utils.dart';
import '../widgets/login_widget/constants.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login_page';

  MyAppState? _appState;

  SignupData? _signupData;

  BuildContext? _dialogContext;

  BuildContext? _loadingContext;

  ColorScheme? _colorScheme;

  TextTheme? _textTheme;

  WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000));

  Future<String?> _loginUser(LoginData data) async {
    var loginUserId = await _appState!.login(data.name, data.password);
    if (loginUserId == null) {
      return _appState!.errorMsg;
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null) {
      return "Password can't be empty";
    }

    if (password.length < 8 || password.length > 16) {
      return "Password must has length from 8 to 16";
    }

    RegExp invisibleCharRegex = RegExp(r'[\x00-\x1F\x7F]');
    if (invisibleCharRegex.hasMatch(password)) {
      return "Password can't contain invisible characters";
    }

    RegExp uppercaseRegex = RegExp(r'[A-Z]');
    if (!uppercaseRegex.hasMatch(password)) {
      return "Password must contain at least one uppercase letter";
    }

    RegExp lowercaseRegex = RegExp(r'[a-z]');
    if (!lowercaseRegex.hasMatch(password)) {
      return "Password must contain at least one lowercase letter";
    }

    RegExp digitRegex = RegExp(r'\d');
    if (!digitRegex.hasMatch(password)) {
      return "Password must contain at least one digit";
    }

    RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!specialCharRegex.hasMatch(password)) {
      return "Password must contain at least one special letter";
    }

    // TODO: continuous number sequence, alphabet sequence and usqwert keyboard sequence.
    // RegExp numberSequenceRegex = RegExp(r'.*\b\d{3,}\b.*');
    // if (numberSequenceRegex.hasMatch(password)) {
    //   return "Password contains number sequence";
    // }

    // RegExp alphabetSequenceRegex = RegExp(r'^a*b*c*d*e*f*g*h*i*j*k*l*m*n*o*p*q*r*s*t*u*v*w*x*y*z*A*B*C*D*E*F*G*H*I*J*K*L*M*N*O*P*Q*R*S*T*U*V*W*X*Y*Z*$');
    // if (alphabetSequenceRegex.hasMatch(password)) {
    //   return "Password contains alphabet sequence";
    // }

    return null;
  }

  Future<String?> _signupUser(SignupData data) async {
    _signupData = data;
    var loginUserId = await _appState!.register(
        data.additionalSignupData!['userName']!,
        data.name!,
        data.additionalSignupData!['phoneNumber']!,
        data.password!);
    if (loginUserId == null) {
      return _appState!.errorMsg;
    }
    return null;
  }

  Future<String?> _recoverPassword(String name) async {
    var success = await _appState!.sendVerifyToken(name, 2);
    if (!success) {
      return _appState!.errorMsg;
    }
    return null;
  }

  Future<String?> _resendCode(SignupData data) async {
    var success = await _appState!.sendVerifyToken(data.name!, 1);
    if (!success) {
      return _appState!.errorMsg;
    }
    return null;
  }

  Future<String?> _signupConfirm(String error, LoginData data) async {
    var result = await _appState!.verifySignUpNologin(
        _signupData!.additionalSignupData!['userName']!,
        _signupData!.name!,
        _signupData!.additionalSignupData!['phoneNumber']!,
        _signupData!.password!,
        error);
    if (result == null) {
      return _appState!.errorMsg;
    }
    return null;
  }

  Future<String?> _recoverConfirm(String error, LoginData data) async {
    var result = await _appState!.verifyResetPasswordNologin(
        data.password, data.password, error, data.name);
    if (result == null) {
      return _appState!.errorMsg;
    }
    return null;
  }

  Future<String?> _showWebView(
      BuildContext context, Uri authorizationUrl) async {
    String? result;
    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('progress: $progress');
          },
          onPageStarted: (String url) {
            print('start url: $url');
          },
          onPageFinished: (String url) {
            print('finish url: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print(error);
            _controller.goBack();
          },
          onNavigationRequest: (NavigationRequest request) {
            // User cancels login.
            if (request.url.contains('access_denied')) {
              Navigator.pop(_dialogContext!, 'You have canceled login');
              return NavigationDecision.prevent;
            }
            if (request.url
                .contains(GitHubOAuth2Client.redirectUrl.toString())) {
              Navigator.pop(_dialogContext!, request.url);
              return NavigationDecision.prevent;
              // return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(authorizationUrl);
    if (context.mounted) {
      result = await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          _dialogContext = context;
          return Scaffold(
              appBar: AppBar(
                backgroundColor: _colorScheme!.primary,
                iconTheme: IconThemeData(color: _colorScheme!.onSecondary),
              ),
              body: WebViewWidget(controller: _controller));
        },
      );
    }
    return result;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _loadingContext = context;
        return Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(_loadingContext!).pop();
  }

  Future<String?> _signInWithGitHub(BuildContext context) async {
    var authorizationUrl = GitHubOAuth2Client.getAuthorizationUrl();
    print(authorizationUrl);
    var result = await _showWebView(context, authorizationUrl);
    if (context.mounted &&
        result != null &&
        result.contains(GitHubOAuth2Client.redirectUrl.toString())) {
      _showLoadingDialog(context);
      try {
        // Future.delayed(Duration(hours: 1));
        var accessTokenResult = await _appState!.loginByGitHub(result);
      } catch (e) {
        // Handle any errors here
      } finally {
        if (_loadingContext!.mounted) {
          _hideLoadingDialog();
        }
      }
      return null;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    _colorScheme = colorScheme;
    _textTheme = textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        if (_dialogContext != null && _dialogContext!.mounted) {
          Navigator.pop(_dialogContext!);
          return false;
        }
        return true;
      },
      child: FlutterLogin(
        title: Constants.appName,
        logo: const AssetImage('assets/images/pm_round.png'),
        logoTag: Constants.logoTag,
        titleTag: Constants.titleTag,
        navigateBackAfterRecovery: true,
        onConfirmRecover: _recoverConfirm,
        onConfirmSignup: _signupConfirm,
        loginAfterSignUp: false,
        hideForgotPasswordButton: false,
        // showDebugButtons: true,
        loginProviders: [
          LoginProvider(
            button: Buttons.gitHub,
            label: 'Sign in with GitHub',
            callback: () async {
              return await _signInWithGitHub(context);
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
        // termsOfService: [
        //   TermOfService(
        //     id: 'newsletter',
        //     mandatory: false,
        //     text: 'Newsletter subscription',
        //   ),
        //   TermOfService(
        //     id: 'general-term',
        //     mandatory: true,
        //     text: 'Term of services',
        //     linkUrl: 'https://github.com/NearHuscarl/flutter_login',
        //   ),
        // ],
        additionalSignupFields: [
          const UserFormField(
            keyName: 'userName',
            displayName: 'User Name',
            icon: Icon(FontAwesomeIcons.userLarge),
          ),
          UserFormField(
            keyName: 'phoneNumber',
            displayName: 'Phone Number',
            userType: LoginUserType.phone,
            fieldValidator: (value) {
              final phoneRegExp = RegExp(
                  '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$');
              if ((value != null &&
                      value.length < 7 &&
                      !phoneRegExp.hasMatch(value)) ||
                  value == null) {
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
          userHint: 'Email',
          passwordHint: 'Password',
          confirmPasswordHint: 'Confirm',
          loginButton: 'LOG IN',
          signupButton: 'REGISTER',
          signUpSuccess:
              'Please check your email, an confirmation code has been sent to your email.',
          // forgotPasswordButton: 'Forgot huh?',
          recoverPasswordButton: 'RESET PASSWORD',
          goBackButton: 'GO BACK',
          confirmPasswordError: 'Not match!',
          recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
          recoverPasswordDescription:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
          recoverPasswordSuccess:
              'Please check your email, an recovery code for resetting password has been sent to your email.',
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
            fillColor: Colors.teal,
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
          //   //TODO: press deep blue color.
          //   splashColor: Color(0xFF361CC4),
          //   // backgroundColor: Color(0xFF0DB826),
          //   // highlightColor: Color(0xFF361CC4),
          //   // elevation: 1.0,
          //   // highlightElevation: 4.0,
          //   // shape: BeveledRectangleBorder(
          //   //   borderRadius: BorderRadius.circular(10),
          //   // ),
          //   // shape:
          //   //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          //   // shape: CircleBorder(side: BorderSide(color: Colors.green)),
          //   // shape: ContinuousRectangleBorder(
          //   //     borderRadius: BorderRadius.circular(55.0)),
          // ),
        ),
        userValidator: (value) {
          final emailRegex =
              RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
          if (value == null || !emailRegex.hasMatch(value)) {
            return "This isn't a valid email address";
          }
          return null;
        },
        passwordValidator: _validatePassword,
        onLogin: (loginData) {
          return _loginUser(loginData);
        },
        onSignup: (signupData) {
          // debugPrint('Signup info');
          // debugPrint('Name: ${signupData.name}');
          // debugPrint('Password: ${signupData.password}');

          // signupData.additionalSignupData?.forEach((key, value) {
          //   debugPrint('$key: $value');
          // });
          // if (signupData.termsOfService.isNotEmpty) {
          //   debugPrint('Terms of service: ');
          //   for (final element in signupData.termsOfService) {
          //     debugPrint(
          //       ' - ${element.term.id}: ${element.accepted == true ? 'accepted' : 'rejected'}',
          //     );
          //   }
          // }
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
        resendCodeInterval: 60,
        onRecoverPassword: (name) {
          return _recoverPassword(name);
        },
        headerWidget: const IntroWidget(),
      ),
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
