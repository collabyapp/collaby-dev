class AppEnv {
  static const bool allowOfflineDemo = bool.fromEnvironment(
    'ALLOW_OFFLINE_DEMO',
    defaultValue: false,
  );
}
