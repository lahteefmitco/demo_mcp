/// Google OAuth client IDs for [GoogleSignIn.initialize].
abstract final class GoogleOAuthConfig {
  static const iosClientId =
      '615058378594-va499j21oce2qr8raeu6pnr9qo11uv8u.apps.googleusercontent.com';

  /// Android OAuth client (also used for desktop targets).
  static const androidClientId =
      '615058378594-eciila121uj1n8bm97f6odqkr42aarp8.apps.googleusercontent.com';

  /// Web OAuth client — used for web sign-in and as serverClientId on mobile.
  static const webClientId =
      '615058378594-timl7n0gna9800pdai3gdl8p8ijb8ge5.apps.googleusercontent.com';
}
