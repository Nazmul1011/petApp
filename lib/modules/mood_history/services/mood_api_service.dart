import 'package:petapp/core/services/api_service.dart';
import '../models/mood_analytics_model.dart';

class MoodApiService {
  final ApiService _apiService = ApiService();

  Future<MoodAnalyticsResponse?> fetchMoodAnalytics(String filter) async {
    try {
      final response = await _apiService.get(
        '/mood',
        query: {'filter': filter},
      );
      final raw = response.data;
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data != null) {
        return MoodAnalyticsResponse.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      }
    } catch (e) {
      print('[MoodApiService] fetchMoodAnalytics error: $e');
    }
    return null;
  }
}
