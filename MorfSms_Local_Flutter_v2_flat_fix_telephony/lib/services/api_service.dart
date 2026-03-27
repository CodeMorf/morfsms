import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/pairing_config.dart';

class ApiService {
  Future<Map<String, dynamic>> pair(PairingConfig config) async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final pkg = await PackageInfo.fromPlatform();
    final uri = Uri.parse('${config.apiBase}/pair');
    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pairing_token': config.pairingToken,
          'installation_key': config.installationKey,
          'provider_key': config.providerKey,
          'device_uuid': deviceInfo.id,
          'device_name': deviceInfo.model,
          'platform': 'android',
          'package_name': pkg.packageName,
          'app_version': pkg.version,
          'sim_slots': [0, 1],
        }));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> heartbeat(PairingConfig config) async {
    final uri = Uri.parse('${config.apiBase}/heartbeat');
    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'installation_key': config.installationKey,
          'provider_key': config.providerKey,
          'sim_slots': [0, 1],
        }));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> pullJobs(PairingConfig config) async {
    final uri = Uri.parse('${config.apiBase}/pull_jobs');
    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider_key': config.providerKey,
          'installation_key': config.installationKey,
          'limit': 10,
        }));
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return (map['jobs'] as List?) ?? [];
  }

  Future<void> pushResult(PairingConfig config, Map<String, dynamic> payload) async {
    final uri = Uri.parse('${config.apiBase}/push_result');
    await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));
  }
}
