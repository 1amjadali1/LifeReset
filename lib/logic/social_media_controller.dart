import 'package:flutter/foundation.dart';

import '../core/utils/date_utils.dart';
import '../data/models/social_media_entry.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/social_media_repository.dart';

class SocialMediaController extends ChangeNotifier {
  SocialMediaController({
    required this.repository,
    required this.settingsRepository,
  });

  final SocialMediaRepository repository;
  final SettingsRepository settingsRepository;

  List<SocialMediaEntry> _todayEntries = [];
  int _todayTotalMinutes = 0;
  int _dailyLimitMinutes = 60;
  bool _isLoading = false;
  String? _errorMessage;

  List<SocialMediaEntry> get todayEntries => List.unmodifiable(_todayEntries);
  int get todayTotalMinutes => _todayTotalMinutes;
  int get dailyLimitMinutes => _dailyLimitMinutes;
  bool get isLimitExceeded => _todayTotalMinutes > _dailyLimitMinutes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Progress fraction of daily limit (can exceed 1.0).
  double get limitFraction {
    if (_dailyLimitMinutes <= 0) return 0.0;
    return _todayTotalMinutes / _dailyLimitMinutes;
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dailyLimitMinutes = await settingsRepository.getDailySocialMediaLimit();
      final todayStr = AppDateUtils.todayString;
      _todayEntries = await repository.getEntriesForDate(todayStr);
      _todayTotalMinutes = await repository.getTotalMinutesForDate(todayStr);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEntry({
    required String appName,
    required int durationMinutes,
    String? notes,
    DateTime? date,
  }) async {
    final trimmedName = appName.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'App name cannot be empty.';
      notifyListeners();
      return false;
    }
    if (durationMinutes <= 0) {
      _errorMessage = 'Duration must be at least 1 minute.';
      notifyListeners();
      return false;
    }

    final targetDate = date ?? DateTime.now();
    final entry = SocialMediaEntry(
      appName: trimmedName,
      durationMinutes: durationMinutes,
      dateString: AppDateUtils.toDateString(targetDate),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );

    try {
      await repository.addEntry(entry);
      await loadData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await repository.deleteEntry(id);
      await loadData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLimit(int minutes) async {
    if (minutes <= 0) return;
    try {
      await settingsRepository.setDailySocialMediaLimit(minutes);
      _dailyLimitMinutes = minutes;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
