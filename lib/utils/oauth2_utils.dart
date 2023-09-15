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
      Uri.parse('http://${API.host}${API.githubRedirectUrl}');

  static Uri getAuthorizationUrl() {
    var grant = oauth2.AuthorizationCodeGrant(
      identifier,
      authorizationEndpoint,
      tokenEndpoint,
      // secret: secret,
    );

    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    return grant.getAuthorizationUrl(redirectUrl,
        scopes: {'user:email', 'read:profile'});

    // state: StringUtils.generateRandomString(128)

    // Redirect the resource owner to the authorization URL. Once the resource
    // owner has authorized, they'll be redirected to `redirectUrl` with an
    // authorization code. The `redirect` should cause the browser to redirect to
    // another URL which should also have a listener.
    //
    // `redirect` and `listen` are not shown implemented here. See below for the
    // details.
    // redirect(authorizationUrl, context);

    // var responseUrl = await listen(redirectUrl);

    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    // return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
  }
}
