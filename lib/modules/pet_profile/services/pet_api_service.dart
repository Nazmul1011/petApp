import 'package:petapp/core/services/api_service.dart';
import '../models/pet_model.dart';

class PetApiService {
  final ApiService _api = ApiService();

  Future<List<PetModel>> getAllPets() async {
    try {
      final response = await _api.get('/pets');
      print("[PetApiService] Response: ${response.data}");

      final dynamic dataWrapper = response.data['data'];
      if (dataWrapper == null) {
        print("[PetApiService] Data wrapper is null");
        return [];
      }

      // Check if it's paginated (has items) or a direct list
      final List? dataList = dataWrapper is Map
          ? dataWrapper['items']
          : (dataWrapper is List ? dataWrapper : null);

      if (dataList == null) {
        print("[PetApiService] Could not find list in response data");
        return [];
      }

      return dataList.map((json) => PetModel.fromJson(json)).toList();
    } catch (e) {
      print("[PetApiService] Error: $e");
      rethrow;
    }
  }

  Future<PetModel> createPet(Map<String, dynamic> data) async {
    final response = await _api.post('/pets', data: data);
    return PetModel.fromJson(response.data['data']);
  }

  Future<PetModel> updatePet(String id, Map<String, dynamic> data) async {
    final response = await _api.patch('/pets/$id', data: data);
    return PetModel.fromJson(response.data['data']);
  }

  Future<void> deletePet(String id) async {
    await _api.delete('/pets/$id');
  }

  Future<void> setActivePet(String petId) async {
    await _api.patch('/pets/active', data: {'petId': petId});
  }
}
