import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pairing_config.dart';

class StorageService {
  static const _pairingKey = 'pairing_config';

  Future<void> savePairing(PairingConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pairingKey, jsonEncode(config.toJson()));
  }

  Future<PairingConfig?> getPairing() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pairingKey);
    if (raw == null || raw.isEmpty) return null;
    return PairingConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
