import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';

const _key = 'entries';
const _photoKey = 'photos';

Future<void> saveEntries(List<Entry> entries) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
  await prefs.setStringList(_key, jsonList);
}

Future<List<Entry>> loadEntries() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = prefs.getStringList(_key) ?? [];
  return jsonList.map((s) => Entry.fromJson(jsonDecode(s))).toList();
}

// Photo locations, stored by entry id
Future<Map<String, String>> loadPhotos() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_photoKey);
  if (saved == null) return {};
  return Map<String, String>.from(jsonDecode(saved));
}

Future<void> savePhoto(String entryId, String path) async {
  final photos = await loadPhotos();
  photos[entryId] = path;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_photoKey, jsonEncode(photos));
}