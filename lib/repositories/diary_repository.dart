import '../core/repository_exceptions.dart';
import '../models/diary_entry.dart';
import '../service/app_database.dart';
import 'i_diary_repository.dart';

class DiaryRepositoryImpl implements IDiaryRepository {
  final AppDatabase _db = AppDatabase.instance;

  @override
  Future<void> addEntry(DiaryEntry entry) async {
    try {
      await _db.create(entry);
    } catch (e) {
      RepositoryException("Failed to load diary entries : $e");
    }
  }

  @override
  Future<void> deleteEntry(int id) async {
    try {
      await _db.delete(id);
    } catch (e) {
      RepositoryException("Failed to delete entry: $e");
    }
  }

  @override
  Future<List<DiaryEntry>> getEntries({
    String? searchQuery,
    String? moodFilter,
    bool onlyFavorites = false,
  }) async {
    try {
      return await _db.readAllEntries(
        searchQuery: searchQuery,
        moodFilter: moodFilter,
        onlyFavorites: onlyFavorites,
      );
    } catch (e) {
      throw RepositoryException("Failed to load diary entries: $e");
    }
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    try {
      await _db.update(entry);
    } catch (e) {
      RepositoryException("Failed to update entry: $e");
    }
  }
}
