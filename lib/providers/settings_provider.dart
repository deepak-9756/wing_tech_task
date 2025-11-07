import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/firestore_service.dart';

class SettingsProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();

  SettingsModel _settings = SettingsModel();
  bool _isLoading = false;
  String? _error;

  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;

    try {
      _settings = await _firestoreService.getSettings();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateSettings(SettingsModel settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateSettings(settings);
      _settings = settings;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
