import '../models/diary_entry.dart';

abstract class IDiaryRepository {

  Future<List<DiaryEntry>> getEntries({
    String? searchQuery,
    String? moodFilter,
    bool onlyFavorites = false,
  });

  Future<void> addEntry(DiaryEntry entry);

  Future<void> updateEntry(DiaryEntry entry);
  
  Future<void> deleteEntry(int id);

}