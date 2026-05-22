import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/google_oauth_config.dart';

/// Mobile/desktop Google Sign-In setup using [defaultTargetPlatform] (not dart:io).
Future<void> configureGoogleSignIn() {
  final clientId = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => GoogleOAuthConfig.iosClientId,
    TargetPlatform.android => GoogleOAuthConfig.androidClientId,
    _ => GoogleOAuthConfig.androidClientId,
  };

  return GoogleSignIn.instance.initialize(
    clientId: clientId,
    serverClientId: GoogleOAuthConfig.webClientId,
  );
}
