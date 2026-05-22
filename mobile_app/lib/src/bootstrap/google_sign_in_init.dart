export 'google_sign_in_init_stub.dart'
    if (dart.library.html) 'google_sign_in_init_web.dart'
    if (dart.library.io) 'google_sign_in_init_mobile.dart';
