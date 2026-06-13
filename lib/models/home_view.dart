import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import '../data/repositories/studio_repository.dart';
import '../data/services/vpn_service.dart';
import './studio.dart';
import './vpn_config.dart';

enum VpnConnectionState { idle, pinging, connecting, connected, error }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required StudioRepository repository,
    required VpnService vpnService,
    required this.studio, // FIX: Used initializing formal
    required List<VpnConfig>
    configs, // Kept in constructor in case you pass it, but removed the unused private field
  }) : _repository = repository,
       _vpnService = vpnService;

  final StudioRepository _repository;
  final VpnService _vpnService;

  final Studio studio;

  VpnConnectionState _connectionState = VpnConnectionState.idle;
  VpnConnectionState get connectionState => _connectionState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  VpnConfig? _activeConfig;
  VpnConfig? get activeConfig => _activeConfig;

  V2RayStatus? _v2rayStatus;
  V2RayStatus? get v2rayStatus => _v2rayStatus;

  StreamSubscription<V2RayStatus>? _statusSub;

  Future<void> connect() async {
    _connectionState = VpnConnectionState.pinging;
    _errorMessage = null;
    notifyListeners();

    try {
      final fastest = await _repository.findFastestConfig();

      if (fastest == null) {
        _errorMessage = 'No reachable servers rn. Try again later 😔';
        _connectionState = VpnConnectionState.error;
        notifyListeners();
        return;
      }

      _activeConfig = fastest;
      _connectionState = VpnConnectionState.connecting;
      notifyListeners();

      final hasPermission = await _vpnService.requestPermission();
      if (!hasPermission) {
        _errorMessage = 'VPN permission denied. We need that W 🙏';
        _connectionState = VpnConnectionState.error;
        notifyListeners();
        return;
      }

      await _vpnService.connect(fastest);

      // FIX: Explicitly typing the stream listener ensures 'status' is recognized as V2RayStatus, not Object?
      _statusSub = _vpnService.statusStream.listen((V2RayStatus status) {
        _v2rayStatus = status;
        if (status.state == 'CONNECTED') {
          _connectionState = VpnConnectionState.connected;
        } else if (status.state == 'DISCONNECTED') {
          _connectionState = VpnConnectionState.idle;
          _activeConfig = null;
        }
        notifyListeners();
      });

      _connectionState = VpnConnectionState.connected;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to connect. It ain\'t it rn 💀';
      _connectionState = VpnConnectionState.error;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _vpnService.disconnect();
    _statusSub?.cancel();
    _activeConfig = null;
    _connectionState = VpnConnectionState.idle;
    _v2rayStatus = null;
    notifyListeners();
  }

  bool get isConnected => _connectionState == VpnConnectionState.connected;
  bool get isBusy =>
      _connectionState == VpnConnectionState.pinging ||
      _connectionState == VpnConnectionState.connecting;

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }
}
