import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pairing_config.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'qr_pair_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  final ApiService _api = ApiService();
  PairingConfig? _config;
  bool _online = false;
  int _queued = 0;
  int _sent = 0;
  final List<String> _logs = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final config = await _storage.getPairing();
    if (!mounted) return;
    if (config != null) {
      setState(() => _config = config);
      await _pairAndSync();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 20), (_) => _sync());
    }
  }

  Future<void> _pairAndSync() async {
    final config = _config;
    if (config == null) return;
    final response = await _api.pair(config);
    _addLog('Pair: ${response['ok'] == true ? 'OK' : 'FAIL'}');
    setState(() => _online = response['ok'] == true);
    await _sync();
  }

  Future<void> _sync() async {
    final config = _config;
    if (config == null) return;
    try {
      await _api.heartbeat(config);
      final jobs = await _api.pullJobs(config);
      setState(() {
        _online = true;
        _queued = jobs.length;
      });
      for (final job in jobs) {
        final recipient = job['recipient']?.toString() ?? '';
        final simSlot = job['sim_slot']?.toString() ?? '0';
        _addLog('[code] SEND -> $recipient via SIM $simSlot');
        await _api.pushResult(config, {
          'queue_id': job['id'],
          'status': 'sent',
          'installation_key': config.installationKey,
          'result': {'mock': true, 'note': 'Integrar envío real SMS aquí'},
        });
        setState(() {
          _sent += 1;
        });
      }
    } catch (e) {
      setState(() => _online = false);
      _addLog('Error sync: $e');
    }
  }

  void _addLog(String line) {
    setState(() {
      _logs.insert(0, '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')} $line');
      if (_logs.length > 25) _logs.removeLast();
    });
  }

  Future<void> _openPairing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrPairScreen(
          onPaired: (config) async {
            await _storage.savePairing(config);
            setState(() => _config = config);
            await _pairAndSync();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(title: 'Pendientes', value: _queued.toString()),
      _StatCard(title: 'Enviados', value: _sent.toString()),
      _StatCard(title: 'Estado', value: _online ? 'OK' : 'OFF'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MorfSms Local'),
        actions: [
          IconButton(onPressed: _openPairing, icon: const Icon(Icons.qr_code_scanner_rounded)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Conexión con Perfex', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Chip(
                          label: Text(_online ? 'Conectado' : 'Sin conectar'),
                          backgroundColor: _online ? const Color(0xFF0B5030) : const Color(0xFF4B1D1D),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_config?.apiBase ?? 'Escanea el QR desde el módulo Perfex'),
                    const SizedBox(height: 16),
                    Row(
                      children: cards.map((e) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: e))).toList(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      children: [
                        FilledButton.icon(onPressed: _openPairing, icon: const Icon(Icons.qr_code_2), label: const Text('Escanear QR')),
                        OutlinedButton.icon(onPressed: _sync, icon: const Icon(Icons.sync), label: const Text('Sincronizar')),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Actividad en vivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07101C),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF22496F)),
                      ),
                      child: SelectableText(_logs.isEmpty ? '[code] Esperando actividad...' : _logs.join('\n'), style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF7DF9FF))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF90B4DE))),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3AC8FF))),
          ],
        ),
      ),
    );
  }
}
