import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'base_api_response.dart';

abstract class BaseService {
  final ApiService api = ApiService.instance;
  final AuthTokenService authTokenService = AuthTokenService();

  Future<BaseApiResponse<T>> safeRequest<T>({
    required Future<Response> Function() request,
    required T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await request();
      final data = response.data;

      debugPrint('safeRequest: statusCode=${response.statusCode}, dataType=${data.runtimeType}');

      // One-liner: normalize + attach status code
      return BaseApiResponse<T>.fromHttp(response, fromJson);
    } on AppException catch (e) {
      // Raised by handleError(...) with statusCode attached
      debugPrint('safeRequest: AppException caught: ${e.message} (status=${e.statusCode})');
      return BaseApiResponse<T>(
        success: false,
        message: e.message,
        data: null,
        statusCode: e.statusCode,
      );
    } on DioException catch (e) {
      final isConnectionError = e.type == DioExceptionType.connectionError ||
          (e.message?.toLowerCase().contains('failed host lookup') ?? false);

      debugPrint('safeRequest: DioException caught: ${e.message}');
      debugPrint('safeRequest: isConnectionError: $isConnectionError');

      return BaseApiResponse<T>(
        success: false,
        message: isConnectionError
            ? 'Check your internet or try again later'
            : 'Something went wrong. Please try again',
        data: null,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('safeRequest: Unknown error caught: $e');
      debugPrint('StackTrace: $stackTrace');

      return BaseApiResponse<T>(
        success: false,
        message: 'Something went wrong. Please try again',
        data: null,
        statusCode: null,
      );
    }
  }
}
