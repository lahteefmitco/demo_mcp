import 'package:google_sign_in/google_sign_in.dart';

/// Fallback when neither web nor IO library is available.
Future<void> configureGoogleSignIn() {
  return GoogleSignIn.instance.initialize();
}
