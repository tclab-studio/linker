import 'dart:async';
import 'dart:io';
import '../../models/vpn_config.dart';

class PingService {
  Future<int?> pingHost(String host, int port) async {
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      stopwatch.stop();
      await socket.close();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  Future<VpnConfig?> findFastest(List<VpnConfig> configs) async {
    if (configs.isEmpty) return null;

    final futures = configs.map((config) async {
      final ms = await pingHost(config.host, config.port);
      return (config: config, ms: ms);
    }).toList();

    final results = await Future.wait(futures);

    final reachable = results.where((r) => r.ms != null).toList()
      ..sort((a, b) => a.ms!.compareTo(b.ms!));

    if (reachable.isEmpty) return null;

    final best = reachable.first;
    best.config.pingMs = best.ms;
    return best.config;
  }
}
