import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftManager {
  static const String _signUpKey = 'signup_draft';
  static const String _eventKey = 'event_draft';

  static Future<void> saveSignUpDraft(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signUpKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadSignUpDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_signUpKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> clearSignUpDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signUpKey);
  }

  static Future<void> saveEventDraft(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eventKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadEventDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_eventKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> clearEventDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventKey);
  }
}
