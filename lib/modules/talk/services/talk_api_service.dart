import 'package:petapp/core/services/api_service.dart';
import '../models/talk_session_model.dart';
import '../models/translation_model.dart';

class TalkApiService {
  final ApiService _apiService = ApiService();

  /// Step 1 — Create (or resume) a talk session for the active pet.
  Future<TalkSessionModel?> createSession({String? petId}) async {
    try {
      final response = await _apiService.post(
        '/talk/session',
        data: petId != null ? {'petId': petId} : {},
      );
      final raw = response.data;
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data != null) {
        return TalkSessionModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      }
    } catch (e) {
      print('[TalkApiService] createSession error: $e');
    }
    return null;
  }

  /// Step 2 — Submit a recorded audio file for translation.
  Future<TranslationModel?> createTranslation({
    required String sessionId,
    required String inputType, // 'HUMAN_VOICE' | 'PET_VOICE'
    required String direction, // 'HUMAN_TO_PET' | 'PET_TO_HUMAN'
    String? inputText,
    String? inputAudioUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'sessionId': sessionId,
        'inputType': inputType,
        'direction': direction,
      };
      if (inputText != null) body['inputText'] = inputText;
      if (inputAudioUrl != null) body['inputAudioUrl'] = inputAudioUrl;

      final response = await _apiService.post('/talk/translate', data: body);
      final raw = response.data;
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data != null) {
        return TranslationModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      }
    } catch (e) {
      print('[TalkApiService] createTranslation error: $e');
    }
    return null;
  }

  /// Step 3 — Save a completed translation with a user-defined name.
  Future<TranslationModel?> saveTranslation({
    required String translationId,
    required String savedName,
    String? mood,
  }) async {
    try {
      final body = <String, dynamic>{'savedName': savedName};
      if (mood != null) body['mood'] = mood;

      final response = await _apiService.patch(
        '/talk/save/$translationId',
        data: body,
      );
      final raw = response.data;
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data != null) {
        return TranslationModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      }
    } catch (e) {
      print('[TalkApiService] saveTranslation error: $e');
    }
    return null;
  }

  /// Step 4 — Fetch all saved translations for the active pet.
  Future<List<TranslationModel>> listSaved({String? search}) async {
    try {
      final query = <String, dynamic>{};
      if (search != null && search.isNotEmpty) query['search'] = search;

      final response = await _apiService.get('/talk/saved', query: query);
      final raw = response.data;
      final outer = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;

      List<dynamic> items = [];
      if (outer is Map && outer.containsKey('items')) {
        items = outer['items'] as List<dynamic>;
      } else if (outer is List) {
        items = outer;
      }

      return items
          .map(
            (e) =>
                TranslationModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      print('[TalkApiService] listSaved error: $e');
      return [];
    }
  }
}
