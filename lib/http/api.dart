class API {
  static const demoMpd = 'https://$host/mpd/c.mpd';

  static const demoAppcastXml = 'https://$host/xml/appcast.xml';

  /// Host of playlist server.
  static const host = 'playlistmaster.fun';
  // static const host = '192.168.158.49:8443';
  // static const host = '192.168.8.171:8080';
  // static const host = '192.168.0.114:8080';

  /// Get latest release in github.
  static const getLatestRelease = 'https://api.github.com/repos/loph3xertoi/playlist_master_android/releases/latest';

  /// Redirect url for oauth2 by github.
  static const githubRedirectUrl = '/login/oauth2/github';

  /// Redirect url for oauth2 by google.
  static const googleRedirectUrl = '/login/oauth2/google';

  /// Get user information according to [uid] in [platform].
  /// api: GET /user/[uid]?platform=[platform]
  static const user = '/user';

  /// Get basic pms user information of current login user.
  /// api: GET /user/basic
  static const basicUser = '/user/basic';

  /// Get detail song according to [songId] in [platform].
  /// api: GET /song/[songId]?platform=[platform]
  static const detailSong = '/song';

  /// Get all similar songs according to [songId] in [platform].
  /// api: GET /similarSongs/[songId]?platform=[platform]
  static const similarSongs = '/similarSongs';

  /// Search songs according to [keywords] in [platform] with [pageNo] and [pageSize].
  /// api: GET /search/song/[keywords]?pageNo=[pageNo]&pageSize=[pageSize]&platform=[platform]
  static const searchSong = '/search/song';

  // /// Get song's link according to [songMid], [mediaMid] and [type] in [platform].
  // /// api: GET /songLink/[songMid]?mediaMid=[mediaMid]&type=[type]&platform=[platform]
  // static const songLink = '/songLink';

  /// Get all songs' link according to [SongIds] in [platform].
  /// api: GET /songsLink/[SongIds]?platform=[platform]
  /// TODO: api need to update for handle flv in bilibili for some resources.
  static const songsLink = '/songsLink';

  /// Get all MVs' links according to [vids] in [platform].
  /// api: GET /mvLink/[vids]?platform=[platform]
  static const mvLink = '/mvLink';

  /// Get detail MV according to [vid] in [platform].
  /// api: GET /mv/[vid]?platform=[platform]
  static const detailMV = '/mv';

  /// Get all related MVs according to [songId] in [platform].
  /// api: GET /relatedMV/[songId]?mvId=[mvId]&limit=[limit]&platform=[platform]
  static const relatedMV = '/relatedMV';

  /// Get all libraries according to [uid] in [platform].
  /// api: GET /libraries?id=[uid]&platform=[platform]
  static const libraries = '/libraries';

  /// Get detail library according to [library] in [platform].
  /// api: GET /library/[library]?platform=[platform]
  static const detailLibrary = '/library';

  /// Create library in [platform] with [name].
  /// api: POST /library?platform=[platform] {'name': [name]}
  static const createLibrary = '/library';

  /// Update library in [platform].
  /// api: PUT /library?platform=[platform] {'name': [name], 'intro': [intro], 'cover': [cover]}
  static const updateLibrary = '/library';

  /// Delete library in [platform] with id [libraries].
  /// api: DELETE /library/[libraries]?platform=[platform]
  static const deleteLibrary = '/library';

  /// Add songs to library with [libraryId] in [platform],
  /// [tid] is used to evict cache.
  /// api: POST /addSongsToLibrary?platform=[platform] {'libraryId':[libraryId],'songsId':[songsId],'tid':[tid]}
  static const addSongsToLibrary = '/addSongsToLibrary';

  /// Move songs from one library to another library in [platform],
  /// [fromTid] and [toTid] is used to evict cache.
  /// api: PUT /moveSongsToOtherLibrary?platform=[platform] {'songsId':[songsId],'fromLibrary':[fromLibrary],
  /// 'toLibrary':[toLibrary], 'fromTid':[fromTid], 'toTid':[toTid]}
  static const moveSongsToOtherLibrary = '/moveSongsToOtherLibrary';

  /// Remove songs from library with [libraryId] in [platform],
  /// [tid] is used to evict cache.
  /// api: DELETE /removeSongsFromLibrary?libraryId=[libraryId]&songsId=[songsId]&platform=[platform]&tid=[tid]
  static const removeSongsFromLibrary = '/removeSongsFromLibrary';

  /// Get bilibili splash screen images.
  /// api: GET /cors/bili/splash
  static const getBiliSplashScreenImage = '/cors/bili/splash';

  /// Get search suggestions in bilibili.
  /// api: GET /cors/bili/suggestions/[keyword]
  static const getSearchSuggestions = '/cors/bili/suggestions';

  /// Get image from pms for cors and referrer reason.
  /// api: GET /cors/image?imageUrl=[imageUrl]
  static const getImage = '/cors/image';

  /// Check if current token is expired.
  /// api: GET /check
  static const check = '/check';

  /// Update the credential of third app.
  /// api: PUT /credential?platform=[platform] {thirdId: [thirdId], thirdCookie: [thirdCookie]}
  static const credential = '/credential';

  /// Forget user's password, send verifying code to user's email, need login first.
  /// api: GET /forgot/password
  static const forgotPassword = '/forgot/password';

  /// Bind email, send verifying code to user's email, need login first.
  /// api: GET /bind/email?email=[email]
  static const bindEmail = '/bind/email';

  /// Send token to yur email for verifying, no need to login first, type: 1 for sign up, 2 for reset password.
  /// api: GET /sendcode?email=[email]&type=[type]
  static const sendCode = '/sendcode';

  /// PMS user login endpoint.
  /// api: POST /login {name: [name], password: [password]}
  static const login = '/login';

  /// Login by github.
  /// api: GET /login/oauth2/github?code=[authorization code]
  static const loginByGitHub = '/login/oauth2/github';

  /// Logout current account.
  /// api: GET /logout
  static const logout = '/logout';

  /// Register account in pms.
  /// api: POST /register {name: [name], email: [email], password: [password]}
  static const register = '/register';

  /// Verify token for resetting user's password, need to log in first.
  /// api: POST /verify/resetPassword {password: [password], repeatedPassword: [repeatedPassword], token: [token]}
  static const verifyResetPass = '/verify/resetPassword';

  /// Verify token for binding user's email, need to log in first.
  /// api: POST /verify/bindEmail {email: [email], token: [token]}
  static const verifyBindEmail = '/verify/bindEmail';

  /// Verify token for resetting user's password, no need to log in.
  /// api: POST /verify/nologin/resetPassword {password: [password], repeatedPassword: [repeatedPassword], email: [email], token: [token]}
  static const verifyTokenForResetPasswordNologin =
      '/verify/nologin/resetPassword';

  /// Verify token for sign up new account, no need to log in.
  /// api: POST /verify/nologin/signUp {name: [name], email: [email], phoneNumber: [phoneNumber], password: [password], token: [token], registrationCode: [registrationCode]}
  static const verifyTokenForSignUpNologin = '/verify/nologin/signUp';

  /// Convert raw image url to image url for pms.
  /// TODO: network_cache_image don't support withCredential, can't set cookie in request header in flutter web.
  static String convertImageUrl(String rawImageUrl) {
    return Uri.https(API.host, API.getImage, {'imageUrl': rawImageUrl})
        .toString();
  }
}
