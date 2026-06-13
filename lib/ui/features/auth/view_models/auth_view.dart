import 'package:flutter/material.dart';
import '../../../../data/repositories/studio_repository.dart';
import '../../../../models/studio.dart';
import '../../../../models/vpn_config.dart';

enum AuthState { idle, loading, error }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required StudioRepository repository})
      : _repository = repository;

  final StudioRepository _repository;

  AuthState _state = AuthState.idle;
  AuthState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<({Studio studio, List<VpnConfig> configs})?> verify(
    String studioId,
  ) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.verifyAndLoad(studioId.trim());
      if (result == null) {
        _errorMessage = 'Studio ID not found. Double check that ID bestie 👀';
        _state = AuthState.error;
        notifyListeners();
        return null;
      }
      _state = AuthState.idle;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Connection failed. Check your internet fr fr 😬';
      _state = AuthState.error;
      notifyListeners();
      return null;
    }
  }

  Future<({String? studioId, String? title})> checkSavedSession() =>
      _repository.loadSavedSession();
}