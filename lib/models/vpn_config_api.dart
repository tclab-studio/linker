import '../../models/vpn_config.dart';

class VpnConfigApiModel {
  final String id;
  final String tag;
  final String host;
  final int port;
  final String protocol;
  final Map<String, dynamic> raw;

  VpnConfigApiModel({
    required this.id,
    required this.tag,
    required this.host,
    required this.port,
    required this.protocol,
    required this.raw,
  });

  factory VpnConfigApiModel.fromJson(Map<String, dynamic> json) {
    return VpnConfigApiModel(
      id: json['id']?.toString() ?? '',
      tag: json['tag']?.toString() ?? 'Server',
      host: json['host']?.toString() ?? '',
      port: json['port'] as int? ?? 443,
      protocol: json['protocol']?.toString() ?? 'vmess',
      raw: json,
    );
  }

  VpnConfig toDomain() => VpnConfig(
    id: id,
    tag: tag,
    host: host,
    port: port,
    protocol: protocol,
    raw: raw,
  );
}
