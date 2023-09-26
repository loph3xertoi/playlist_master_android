import 'package:oauth2/oauth2.dart' as oauth2;

import '../config/secrets.dart';
import '../http/api.dart';

class GitHubOAuth2Client {
  static final authorizationEndpoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  static final tokenEndpoint =
      Uri.parse('https://github.com/login/oauth/access_token');
  static const identifier = githubClientId;
  static final redirectUrl =
      Uri.parse('https://${API.host}${API.githubRedirectUrl}');

  static Uri getAuthorizationUrl() {
    var grant = oauth2.AuthorizationCodeGrant(
      identifier,
      authorizationEndpoint,
      tokenEndpoint,
    );
    return grant.getAuthorizationUrl(redirectUrl,
        scopes: {'user:email', 'read:profile'});
  }
}

class GoogleOAuth2Client {
  static final authorizationEndpoint =
      Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');
  static final tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');
  static const identifier = googleClientId;

  static final redirectUrl =
      Uri.parse('https://${API.host}${API.googleRedirectUrl}');

  static Uri getAuthorizationUrl() {
    var grant = oauth2.AuthorizationCodeGrant(
      identifier,
      authorizationEndpoint,
      tokenEndpoint,
    );

    return grant.getAuthorizationUrl(redirectUrl, scopes: {''});
  }
}
