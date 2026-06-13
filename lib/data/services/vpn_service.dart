import 'dart:async';
import 'dart:convert';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import '../../models/vpn_config.dart';

class VpnService {
  late final V2ray _v2ray;

  final StreamController<V2RayStatus> _statusController =
      StreamController<V2RayStatus>.broadcast();

  bool _initialized = false;

  VpnService() {
    _v2ray = V2ray(
      onStatusChanged: (V2RayStatus status) {
        _statusController.add(status);
      },
    );
  }

  Future<void> init() async {
    if (_initialized) return;

    await _v2ray.initialize(
      notificationIconResourceType: 'mipmap',
      notificationIconResourceName: 'ic_launcher',
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    return await _v2ray.requestPermission();
  }

  Future<void> connect(VpnConfig config) async {
    await init();
    final coreConfig = _buildCoreConfig(config);

    await _v2ray.startV2Ray(
      remark: config.tag,
      config: jsonEncode(coreConfig),
      proxyOnly: false,
    );
  }

  Future<void> disconnect() async {
    await _v2ray.stopV2Ray();
  }

  Stream<V2RayStatus> get statusStream => _statusController.stream;

  Map<String, dynamic> _buildCoreConfig(VpnConfig config) {
    if (config.raw.containsKey('outbounds')) {
      return config.raw;
    }

    return {
      'log': {'loglevel': 'warning'},
      'inbounds': [
        {
          'port': 10808,
          'listen': '127.0.0.1',
          'protocol': 'socks',
          'settings': {'udp': true},
        },
      ],
      'outbounds': [
        {
          'protocol': config.protocol,
          'settings': {
            'vnext': [
              {
                'address': config.host,
                'port': config.port,
                'users': [
                  {
                    'id': config.raw['uuid'] ?? '',
                    'alterId': config.raw['alter_id'] ?? 0,
                    'security': config.raw['security'] ?? 'auto',
                  },
                ],
              },
            ],
          },
          'tag': 'proxy',
        },
      ],
    };
  }
}
