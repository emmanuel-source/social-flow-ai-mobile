import 'package:hive_flutter/hive_flutter.dart';

abstract final class LocalStorage {
  static const _settingsBoxName = 'socialflow_settings';
  static const _authBoxName = 'socialflow_auth';
  static const _draftsBoxName = 'socialflow_drafts';
  static const _jobsBoxName = 'socialflow_jobs';

  static late Box<dynamic> _settings;
  static late Box<dynamic> _auth;
  static late Box<dynamic> drafts;
  static late Box<dynamic> jobs;

  static Future<void> initialize({String? path}) async {
    if (path == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(path);
    }
    _settings = await Hive.openBox<dynamic>(_settingsBoxName);
    _auth = await Hive.openBox<dynamic>(_authBoxName);
    drafts = await Hive.openBox<dynamic>(_draftsBoxName);
    jobs = await Hive.openBox<dynamic>(_jobsBoxName);
  }

  static String? get authToken => _auth.get('access_token') as String?;
  static Future<void> setAuthToken(String? value) async {
    if (value == null) {
      await _auth.delete('access_token');
    } else {
      await _auth.put('access_token', value);
    }
  }

  static bool get darkMode =>
      _settings.get('dark_mode', defaultValue: false) as bool;
  static Future<void> setDarkMode(bool value) =>
      _settings.put('dark_mode', value);

  static bool get onboardingCompleted =>
      _settings.get('onboarding_completed', defaultValue: false) as bool;
  static Future<void> setOnboardingCompleted(bool value) =>
      _settings.put('onboarding_completed', value);

  static String? get selectedWorkspaceId =>
      _settings.get('selected_workspace_id') as String?;
  static Future<void> setSelectedWorkspaceId(String value) =>
      _settings.put('selected_workspace_id', value);
}
