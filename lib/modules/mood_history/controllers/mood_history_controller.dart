import 'package:get/get.dart';
import '../models/mood_analytics_model.dart';
import '../services/mood_api_service.dart';

class MoodHistoryController extends GetxController {
  final MoodApiService _api = MoodApiService();

  final isLoading = false.obs;
  final Rx<MoodAnalyticsResponse?> analyticsData = Rx<MoodAnalyticsResponse?>(null);
  
  // Available filters: 'today', '7d', '30d'
  final selectedFilter = '7d'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    
    try {
      // Fetch real data from the backend API
      final response = await _api.fetchMoodAnalytics(selectedFilter.value);
      if (response != null) {
        analyticsData.value = response;
      } else {
        analyticsData.value = null; 
      }
    } catch (e) {
      print('[MoodHistoryController] Error fetching data: $e');
    }
    
    isLoading.value = false;
  }

  MoodAnalyticsResponse _getDummyData() {
    final now = DateTime.now();
    return MoodAnalyticsResponse(
      total: 5,
      filter: selectedFilter.value,
      items: [
        MoodDetectionItem(
          id: '1',
          mood: 'PLAYFUL',
          detectedSound: 'Excited barking',
          confidence: 0.92,
          createdAt: DateTime(now.year, now.month, now.day, 10, 42),
        ),
        MoodDetectionItem(
          id: '2',
          mood: 'HUNGRY',
          detectedSound: 'Whining, pacing',
          confidence: 0.88,
          createdAt: DateTime(now.year, now.month, now.day, 8, 15),
        ),
        MoodDetectionItem(
          id: '3',
          mood: 'CALM',
          detectedSound: 'Gentle breathing',
          confidence: 0.95,
          createdAt: DateTime(now.year, now.month, now.day - 1, 18, 2),
        ),
        MoodDetectionItem(
          id: '4',
          mood: 'ANXIOUS',
          detectedSound: 'Rapid panting, pacing',
          confidence: 0.85,
          createdAt: DateTime(now.year, now.month, now.day - 1, 21, 11),
        ),
        MoodDetectionItem(
          id: '5',
          mood: 'SLEEPY',
          detectedSound: 'Yawning, settling',
          confidence: 0.91,
          createdAt: DateTime(now.year, now.month, now.day - 2, 22, 30),
        ),
      ],
      breakdown: [
        MoodBreakdown(mood: 'PLAYFUL', count: 8, percentage: 40.0, averageConfidence: 0.9),
        MoodBreakdown(mood: 'HUNGRY', count: 4, percentage: 20.0, averageConfidence: 0.85),
        MoodBreakdown(mood: 'CALM', count: 6, percentage: 30.0, averageConfidence: 0.92),
        MoodBreakdown(mood: 'ANXIOUS', count: 1, percentage: 5.0, averageConfidence: 0.8),
        MoodBreakdown(mood: 'SLEEPY', count: 1, percentage: 5.0, averageConfidence: 0.9),
      ],
      patterns: MoodPatterns(
        dominantMood: 'PLAYFUL',
        averageConfidence: 0.89,
        topDetectedSounds: [
          {'sound': 'Excited barking', 'count': 5}
        ],
      ),
    );
  }
}
