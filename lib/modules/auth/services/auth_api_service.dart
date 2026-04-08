import '../../../../core/services/api_service.dart';
import '../../../../core/services/base_api_response.dart';
import '../../../../core/services/base_api_service.dart';
import '../model/user_model.dart';

class AuthApiService extends BaseService {
  /// Authenticate using device unique ID (gameId)
  Future<BaseApiResponse<AuthResponse>> loginWithDevice(String gameId) async {
    return safeRequest(
      request: () => api.post(
        '/auth/device',
        data: {'gameId': gameId},
        apiType: ApiType.public,
      ),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// Refresh tokens
  Future<BaseApiResponse<AuthResponse>> refreshTokens(String refreshToken) async {
    return safeRequest(
      request: () => api.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        apiType: ApiType.public,
      ),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// Get current user profile
  Future<BaseApiResponse<UserModel>> getMe() async {
    return safeRequest(
      request: () => api.get('/auth/me'),
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  /// Logout
  Future<BaseApiResponse<void>> logout() async {
    return safeRequest(
      request: () => api.post('/auth/logout'),
      fromJson: null,
    );
  }

  /// Update user profile (e.g., onboarding completed)
  Future<BaseApiResponse<UserModel>> updateProfile(Map<String, dynamic> data) async {
    return safeRequest(
      request: () => api.patch('/user/', data: data),
      fromJson: (json) => UserModel.fromJson(json),
    );
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns { data: { accessToken, refreshToken, user }, success, message }
    // But API Service handles the 'data' part if it follows the successResponse pattern
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
