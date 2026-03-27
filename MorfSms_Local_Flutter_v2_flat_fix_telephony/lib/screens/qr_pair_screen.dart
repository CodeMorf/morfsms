import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/pairing_config.dart';

class QrPairScreen extends StatefulWidget {
  const QrPairScreen({super.key, required this.onPaired});
  final ValueChanged<PairingConfig> onPaired;

  @override
  State<QrPairScreen> createState() => _QrPairScreenState();
}

class _QrPairScreenState extends State<QrPairScreen> {
  bool _locked = false;

  void _handleCode(String value) {
    if (_locked) return;
    _locked = true;
    try {
      if (!value.startsWith('morfsms://pair?data=')) {
        throw Exception('QR inválido');
      }
      final encoded = Uri.parse(value).queryParameters['data'] ?? '';
      final raw = utf8.decode(base64Decode(Uri.decodeComponent(encoded)));
      final config = PairingConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      widget.onPaired(config);
      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR no válido para MorfSms Local')));
      _locked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR de Perfex')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final code = capture.barcodes.first.rawValue;
              if (code != null) _handleCode(code);
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3AC8FF), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
