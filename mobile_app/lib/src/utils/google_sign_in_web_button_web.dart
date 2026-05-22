import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

/// Renders the GIS sign-in button required on Flutter web.
Widget buildGoogleSignInWebButton() {
  return gsi_web.renderButton();
}
