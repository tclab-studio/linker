import '../../models/studio.dart';
import '../../models/vpn_config.dart';
import '../services/ping_service.dart';
import '../services/session_service.dart';
import '../services/studio_api_service.dart';

class StudioRepository {
  StudioRepository({
    required StudioApiService apiService,
    required SessionService sessionService,
    required PingService pingService,
  }) : _apiService = apiService,
       _sessionService = sessionService,
       _pingService = pingService;

  final StudioApiService _apiService;
  final SessionService _sessionService;
  final PingService _pingService;

  List<VpnConfig>? _cachedConfigs;

  Future<({Studio studio, List<VpnConfig> configs})?> verifyAndLoad(
    String studioId,
  ) async {
    final apiModels = await _apiService.verifyStudio(studioId);
    if (apiModels.isEmpty) return null;

    final configs = apiModels.map((m) => m.toDomain()).toList();
    _cachedConfigs = configs;

    final title = apiModels.first.raw['studio_title']?.toString() ?? 'Studio';
    final studio = Studio(id: studioId, title: title);

    await _sessionService.saveSession(studioId, title);
    return (studio: studio, configs: configs);
  }

  Future<VpnConfig?> findFastestConfig() async {
    final configs = _cachedConfigs;
    if (configs == null || configs.isEmpty) return null;
    return _pingService.findFastest(configs);
  }

  Future<({String? studioId, String? title})> loadSavedSession() =>
      _sessionService.loadSession();

  Future<void> clearSession() => _sessionService.clearSession();
}
