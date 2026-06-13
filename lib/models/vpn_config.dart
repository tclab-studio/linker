class VpnConfig {
  final String id;
  final String tag;
  final String host;
  final int port;
  final String protocol;
  final Map<String, dynamic> raw;
  int? pingMs;

  VpnConfig({
    required this.id,
    required this.tag,
    required this.host,
    required this.port,
    required this.protocol,
    required this.raw,
    this.pingMs,
  });
}
