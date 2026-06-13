import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyStudioId = 'studio_id';
  static const _keyStudioTitle = 'studio_title';

  Future<void> saveSession(String studioId, String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStudioId, studioId);
    await prefs.setString(_keyStudioTitle, title);
  }

  Future<({String? studioId, String? title})> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      studioId: prefs.getString(_keyStudioId),
      title: prefs.getString(_keyStudioTitle),
    );
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStudioId);
    await prefs.remove(_keyStudioTitle);
  }
}
