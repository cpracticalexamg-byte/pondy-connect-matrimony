import '../../domain/models/success_story_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class StoryRepository {
  Future<List<SuccessStoryModel>> getSuccessStories();
  Future<void> submitStory(SuccessStoryModel story);
}

class CsvStoryRepository implements StoryRepository {
  final CsvStore _store;

  CsvStoryRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<List<SuccessStoryModel>> getSuccessStories() async {
    final rows = await _store.readAll(CsvSchema.successStoriesTable);
    return rows.map((e) => SuccessStoryModel.fromMap(e)).toList();
  }

  @override
  Future<void> submitStory(SuccessStoryModel story) async {
    final id = await _store.nextId(CsvSchema.successStoriesTable, 'story_id', 'STR', 6);
    await _store.insert(CsvSchema.successStoriesTable, {
      'story_id': id,
      'groom': story.groom,
      'bride': story.bride,
      'location': story.location,
      'story': story.story,
      'photo': story.photo,
      'wedding_date': story.weddingDate,
      'is_demo': 'false',
    });
  }
}
