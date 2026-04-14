class AppLockConfig {
  const AppLockConfig({
    required this.pinHash,
    required this.pinSalt,
    required this.biometricsEnabled,
  });

  const AppLockConfig.disabled()
    : pinHash = null,
      pinSalt = null,
      biometricsEnabled = false;

  final String? pinHash;
  final String? pinSalt;
  final bool biometricsEnabled;

  bool get isEnabled =>
      pinHash != null &&
      pinHash!.isNotEmpty &&
      pinSalt != null &&
      pinSalt!.isNotEmpty;
}
