import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../config/secrets.dart';
import '../http/api.dart';
import '../states/app_state.dart';
import '../utils/oauth2_utils.dart';
import '../widgets/login_widget/constants.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login_page';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MyAppState? _appState;

  SignupData? _signupData;

  BuildContext? _dialogContext;

  BuildContext? _loadingContext;

  ColorScheme? _colorScheme;

  TextTheme? _textTheme;

  WebViewController? _controller;

  // If current user already exists when login using oauth2.
  bool? _userExists;

  // Login type, 0 for email, 1 for GitHub, 2 for Google.
  int _loginType = 0;

  // Login after sign up.
  bool _loginAfterSignUp = false;

  // webview_universal.WebViewController? _desktopWebViewController;

  PlatformWebViewController? _webController;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _webController = PlatformWebViewController(
        const PlatformWebViewControllerCreationParams(),
      );
      // ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setUserAgent(
      //     'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36')
      // ..setBackgroundColor(const Color(0x00000000));
    } else if (Platform.isAndroid || Platform.isIOS) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36')
        ..setBackgroundColor(const Color(0x00000000));
    }
  }

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

  Future<String?> _preSignup() async {
    _loginType = 0;
    setState(() {
      _loginAfterSignUp = false;
    });
    return '';
  }

  Future<String?> _signupUser(SignupData data) async {
    // Sign up with email.
    if (_loginType == 0) {
      _signupData = data;
      var loginUserId = await _appState!.register(
        data.additionalSignupData!['userName']!,
        data.name!,
        data.additionalSignupData!['phoneNumber']!,
        data.password!,
        data.additionalSignupData!['registrationCode']!,
      );
      if (loginUserId == null) {
        return _appState!.errorMsg;
      }
      return null;
    } else if (_loginType == 1) {
      var ret = await _signInWithGitHub(
          context, data.additionalSignupData!['registrationCode']!);
      return ret;
    } else if (_loginType == 2) {
      var ret = await _signInWithGoogle(
          context, data.additionalSignupData!['registrationCode']!);
      return ret;
    } else {
      throw 'Invalid login type';
    }
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

  Future<String?> _signupConfirm(String token, LoginData data) async {
    var result = await _appState!.verifySignUpNologin(
      _signupData!.additionalSignupData!['userName']!,
      _signupData!.name!,
      _signupData!.additionalSignupData!['phoneNumber']!,
      _signupData!.password!,
      token,
      _signupData!.additionalSignupData!['registrationCode']!,
    );
    if (result == null) {
      return _appState!.errorMsg;
    }
    return null;
  }

  Future<bool> _requireConfirmWhenSignup(LoginData data) async {
    if (_loginType == 0) {
      return true;
    } else {
      // Navigator.of(context).pushReplacementNamed('/home_page');
      // TODO: disable toast for sending verification code.
      return false;
    }
  }

  Future<String?> _recoverConfirm(String token, LoginData data) async {
    var result = await _appState!.verifyResetPasswordNologin(
        data.password, data.password, token, data.name);
    if (result == null) {
      return _appState!.errorMsg;
    }
    return null;
  }

  Future<String> _getWebViewPath() async {
    final document = await getApplicationDocumentsDirectory();
    return p.join(
      document.path,
      'desktop_webview_window',
    );
  }

  Future<String?> _desktopShowWebView(
      BuildContext context, Uri authorizationUrl) async {
    String? result;
    final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
      windowHeight: 1280,
      windowWidth: 720,
      title: 'Login',
      titleBarTopPadding: Platform.isMacOS ? 20 : 0,
      userDataFolderWindows: await _getWebViewPath(),
    ));
    webview
      ..setBrightness(Brightness.dark)
      ..setApplicationNameForUserAgent(
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36')
      ..launch(authorizationUrl.toString())
      ..addOnUrlRequestCallback((url) {
        debugPrint('url: $url');
        final uri = Uri.parse(url);
        if (uri.path == API.githubRedirectUrl) {
          result = url;
          webview.close();
        }
      })
      ..addOnWebMessageReceivedCallback((message) {
        print(message);
      })
      ..onClose.whenComplete(() {
        debugPrint('on close');
      });

    do {
      await Future.delayed(const Duration(seconds: 1));
    } while (result == null);

    // if (context.mounted) {
    //   result = await showDialog<String?>(
    //     context: context,
    //     builder: (BuildContext context) {
    //       _dialogContext = context;
    //       return Scaffold(
    //           appBar: AppBar(
    //             backgroundColor: _colorScheme!.primary,
    //             iconTheme: IconThemeData(color: _colorScheme!.onSecondary),
    //             leading: IconButton(
    //               icon: Icon(Icons.arrow_back),
    //               onPressed: () {
    //                 Navigator.pop(_dialogContext!, 'You have canceled login');
    //               },
    //             ),
    //           ),
    //           body: webview_universal.WebView(
    //             controller: _desktopWebViewController!,
    //           ));
    //     },
    //   );
    // }
    return result;
  }

  Future<String?> _webPlatformShowWebView(
      BuildContext context, Uri authorizationUrl) async {
    String? result;
    _webController!.loadRequest(LoadRequestParams(uri: authorizationUrl));
    if (context.mounted) {
      result = await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          _dialogContext = context;
          return Scaffold(
              appBar: AppBar(
                backgroundColor: _colorScheme!.primary,
                iconTheme: IconThemeData(color: _colorScheme!.onSecondary),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(_dialogContext!, 'You have canceled login');
                  },
                ),
              ),
              body: PlatformWebViewWidget(
                PlatformWebViewWidgetCreationParams(
                    controller: _webController!),
              ).build(context));
        },
      );
    }
    return result;
  }

  Future<String?> _showWebView(
      BuildContext context, Uri authorizationUrl) async {
    String? result;
    _controller!
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
            _controller!.goBack();
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
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(_dialogContext!, 'You have canceled login');
                  },
                ),
              ),
              body: WebViewWidget(controller: _controller!));
        },
      );
    }
    return result;
  }

  Future<String?> _openBrowser(
      BuildContext context, Uri authorizationUrl) async {
    String? result;
    if (!await launchUrlString(
      authorizationUrl.toString(),
      mode: LaunchMode.platformDefault,
    )) {
      throw Exception('Could not launch ${authorizationUrl.toString()}');
    }
    final linksStream = linkStream.listen((String? uri) {
      if (uri!.startsWith(GoogleOAuth2Client.redirectUrl.toString())) {
        result = uri;
      }
    });
    // return result;
    return 'test google';
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

  Future<String?> _signInWithGitHub(BuildContext context,
      [String? registrationCode]) async {
    var authorizationUrl = GitHubOAuth2Client.getAuthorizationUrl();
    print(authorizationUrl);
    String? result;
    if (kIsWeb) {
      result = await _webPlatformShowWebView(context, authorizationUrl);
    } else if (Platform.isAndroid || Platform.isIOS) {
      result = await _showWebView(context, authorizationUrl);
    } else {
      result = await _desktopShowWebView(context, authorizationUrl);
    }
    if (context.mounted &&
        result != null &&
        result.contains(GitHubOAuth2Client.redirectUrl.toString())) {
      _showLoadingDialog(context);
      try {
        // Future.delayed(Duration(hours: 1));
        if (registrationCode != null) {
          result += '&registrationCode=$registrationCode';
        }
        var ret = await _appState!.loginByGitHub(result);
        // Error occur.
        if (ret == null) {
          return _appState!.errorMsg;
        }
        _userExists = ret['userExists'] as bool;
        if (_userExists!) {
          return null;
        } else if (registrationCode == null) {
          return null;
        } else {
          return 'Please input registration code';
        }
      } catch (e) {
        // Handle any errors here
      } finally {
        if (_loadingContext!.mounted) {
          _hideLoadingDialog();
        }
      }
    }
    return 'Unknown error, please send bug report.';
  }

  Future<String?> _signInWithGoogle(BuildContext context,
      [String? registrationCode]) async {
    GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: googleClientId);
    // Revoke google oauth2 authorization.
    var googleSignInAccount = await googleSignIn.signOut();
    bool isSignedIn = await googleSignIn.isSignedIn();
    if (!isSignedIn) {
      try {
        var googleSignInAccount = await googleSignIn.signIn();
        if (googleSignInAccount == null) {
          return 'You have canceled login';
        }
        var serverAuthCode = googleSignInAccount.serverAuthCode;
        var ret =
            await _appState!.loginByGoogle(serverAuthCode!, registrationCode);
        // Error occur.
        if (ret == null) {
          return _appState!.errorMsg;
        }
        _userExists = ret['userExists'] as bool;
        if (_userExists!) {
          return null;
        } else if (registrationCode == null) {
          return null;
        } else {
          return 'Please input registration code';
        }
      } catch (error) {
        return 'Error: $error';
      }
    }
    return 'Unknown error, please send bug report.';
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
        if (kIsWeb) {
          if (await _webController!.canGoBack()) {
            _webController!.goBack();
            return false;
          }
        } else if (Platform.isAndroid || Platform.isIOS) {
          if (await _controller!.canGoBack()) {
            _controller!.goBack();
            return false;
          }
        } else {
          await _controller!.goBack();
          return false;
        }

        if (_dialogContext != null && _dialogContext!.mounted) {
          Navigator.pop(_dialogContext!, 'You have canceled login');
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
        confirmSignupRequired: _requireConfirmWhenSignup,
        loginAfterSignUp: _loginAfterSignUp,
        hideForgotPasswordButton: false,
        // showDebugButtons: true,
        loginProviders: [
          LoginProvider(
            button: Buttons.gitHub,
            label: 'Sign in with GitHub',
            callback: () async {
              _loginType = 1;
              setState(() {
                _loginAfterSignUp = true;
              });
              return await _signInWithGitHub(context);
            },
            providerNeedsSignUpCallback: () async {
              return !_userExists!;
            },
          ),
          LoginProvider(
            icon: FontAwesomeIcons.google,
            callback: () async {
              _loginType = 2;
              setState(() {
                _loginAfterSignUp = true;
              });
              return await _signInWithGoogle(context);
            },
            providerNeedsSignUpCallback: () async {
              return !_userExists!;
            },
          ),
        ],
        termsOfService: [
          TermOfService(
            id: 'privacy-policy',
            mandatory: true,
            text: 'Privacy policy',
            linkUrl: 'https://playlistmaster.fun',
          ),
          TermOfService(
            id: 'general-term',
            mandatory: true,
            text: 'Term of services',
            linkUrl: 'https://playlistmaster.fun',
          ),
        ],
        additionalSignupFields: [
          const UserFormField(
            keyName: 'userName',
            displayName: 'User Name',
            icon: Icon(Icons.person_rounded),
          ),
          UserFormField(
            keyName: 'phoneNumber',
            displayName: 'Phone Number',
            userType: LoginUserType.phone,
            icon: Icon(Icons.smartphone_rounded),
            fieldValidator: (value) {
              final phoneRegExp = RegExp(
                  '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$');
              if ((value == null ||
                  value.length < 7 && !phoneRegExp.hasMatch(value))) {
                return "This isn't a valid phone number";
              }
              return null;
            },
          ),
          UserFormField(
            keyName: 'registrationCode',
            displayName: 'Registration Code',
            icon: Icon(MdiIcons.ticket),
            fieldValidator: (value) {
              final registerCodeRegExp = RegExp('^[2-9A-HJ-NP-Z]{6}\$');
              if ((value == null ||
                  value.length != 6 ||
                  !registerCodeRegExp.hasMatch(value))) {
                return 'Only allow 6 uppercase lettles and numbers';
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
          signupButton: 'SIGN UP',
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
        preSignup: _preSignup,
        onSignup: (signupData) {
          return _signupUser(signupData);
        },
        onSubmitAnimationCompleted: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home_page');
          });
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
