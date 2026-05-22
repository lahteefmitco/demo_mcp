import 'package:google_sign_in/google_sign_in.dart';

import '../config/google_oauth_config.dart';

/// Web-only Google Sign-In setup (no dart:io, no serverClientId).
Future<void> configureGoogleSignIn() {
  return GoogleSignIn.instance.initialize(
    clientId: GoogleOAuthConfig.webClientId,
  );
}
