class PairingConfig {
  final String appName;
  final String apiBase;
  final String pairingToken;
  final String installationKey;
  final String providerKey;

  PairingConfig({
    required this.appName,
    required this.apiBase,
    required this.pairingToken,
    required this.installationKey,
    required this.providerKey,
  });

  factory PairingConfig.fromJson(Map<String, dynamic> json) {
    return PairingConfig(
      appName: json['app_name']?.toString() ?? 'MorfSms Local',
      apiBase: json['api_base']?.toString() ?? '',
      pairingToken: json['pairing_token']?.toString() ?? '',
      installationKey: json['installation_key']?.toString() ?? '',
      providerKey: json['provider_key']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'app_name': appName,
        'api_base': apiBase,
        'pairing_token': pairingToken,
        'installation_key': installationKey,
        'provider_key': providerKey,
      };
}
