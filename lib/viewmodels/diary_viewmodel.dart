import 'package:flutter/cupertino.dart';
import '../core/repository_exceptions.dart';
import '../core/view_state.dart';
import '../models/diary_entry.dart';
import '../repositories/i_diary_repository.dart';

class DiaryViewModel extends ChangeNotifier {
  final IDiaryRepository _repository;

  DiaryViewModel(this._repository);

  // -------------------------------
  // ViewState + Error Message
  // -------------------------------
  ViewState _state = ViewState.idle;
  String _errorMessage = '';

  ViewState get state => _state;

  String get errorMessage => _errorMessage;

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  // -------------------------------
  // DATA
  // -------------------------------
  List<DiaryEntry> _entries = [];

  List<DiaryEntry> get entries => _entries;

  // Filters
  String _searchQuery = '';
  String _moodFilter = 'All';
  bool _showFavoritesOnly = false;

  String get searchQuery => _searchQuery;

  String get moodFilter => _moodFilter;

  bool get showFavoritesOnly => _showFavoritesOnly;

  // -------------------------------
  // Load Entries
  // -------------------------------
  Future<void> loadEntries() async {
    _setState(ViewState.loading);

    try {
      await _fetchEntries();

      if (_entries.isEmpty) {
        _setState(ViewState.empty);
      } else {
        _setState(ViewState.success);
      }
    } on RepositoryException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> _fetchEntries() async {
    _entries = await _repository.getEntries(
      searchQuery: _searchQuery,
      moodFilter: _moodFilter,
      onlyFavorites: _showFavoritesOnly,
    );
  }

  // -------------------------------
  // FILTERS
  // -------------------------------
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadEntries();
  }

  Future<void> setMoodFilter(String mood) async {
    _moodFilter = mood;
    await loadEntries();
  }

  Future<void> toggleFavoritesFilter() async {
    _showFavoritesOnly = !_showFavoritesOnly;
    await loadEntries();
  }

  // -------------------------------
  // CRUD
  // -------------------------------
  Future<void> addEntry(DiaryEntry entry) async {
    try {
      await _repository.addEntry(entry);
      await loadEntries();
    } catch (e) {
      _errorMessage = "Failed to add entry.";
      notifyListeners();
    }
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    try {
      final updatedEntry = entry.copyWith(updatedAt: DateTime.now());
      await _repository.updateEntry(updatedEntry);
      await loadEntries();
    } catch (e) {
      _errorMessage = "Failed to update entry.";
      notifyListeners();
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      await _repository.deleteEntry(id);
      await loadEntries();
    } catch (e) {
      _errorMessage = "Failed to delete entry.";
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(DiaryEntry entry) async {
    try {
      final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);
      await _repository.updateEntry(updatedEntry);
      await loadEntries();
    } catch (e) {
      _errorMessage = "Failed to add favourite.";
      notifyListeners();
    }
  }

  DiaryEntry? getEntryById(int id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = '';
  }
}