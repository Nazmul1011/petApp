import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart' show Get, GetNavigation;
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../../shared/widgets/snack_bar/app_snack_bar.dart';
import '../routes/app_routes.dart';

/// ===========================================================================
///                            ERROR UTILITIES
/// ===========================================================================
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic body;

  AppException(this.message, {this.statusCode, this.body});

  @override
  String toString() => message;
}

/// ===========================================================================
///                            LOGGER SERVICE
/// ===========================================================================
class LoggerService {
  // Singleton instance
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // Create logger with a cleaner SimplePrinter configuration to avoid massive ASCII boxes
  final Logger _logger = Logger(
    printer: SimplePrinter(
      colors: true,
      printTime: false,
    ),
  );

  /// Log debug level message
  void debug(String message) {
    _logger.d(message);
  }

  /// Log verbose level message
  void verbose(String message) {
    _logger.t(message);
  }

  /// Log info level message
  void info(String message) {
    _logger.i(message);
  }

  /// Log warning level message
  void warn(String message) {
    _logger.w(message);
  }

  /// Log error level message with optional error object and stack trace
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log full API request and response
  void logApi({
    required RequestOptions requestOptions,
    Response? response,
    DioException? error,
  }) {
    final buffer = StringBuffer();
    final date = DateTime.now().toString().split('.')[0];
    
    buffer.writeln('┌────────────────────────────────────────────────────────────────────────');
    buffer.writeln('│  $date');
    buffer.writeln('├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄');
    buffer.writeln('│  ━━  REQUEST');
    buffer.writeln('│');
    buffer.writeln('│  [${requestOptions.method.toUpperCase()}]  ${requestOptions.path}');
    buffer.writeln('│');
    buffer.writeln('│  📑  HEADERS');
    
    final maskedHeaders = Map<String, dynamic>.from(requestOptions.headers);
    if (maskedHeaders.containsKey('Authorization')) {
      final auth = maskedHeaders['Authorization'].toString();
      final token = auth.replaceFirst('Bearer ', '');
      final masked = token.length > 12
          ? 'Bearer ${token.substring(0, 6)}...${token.substring(token.length - 6)}'
          : auth;
      maskedHeaders['Authorization'] = masked;
    }
    
    maskedHeaders.forEach((key, value) {
      buffer.writeln('│     $key $value');
    });
    
    buffer.writeln('│');
    buffer.writeln('│  📦  BODY');
    
    final data = requestOptions.data;
    if (data == null) {
      buffer.writeln('│     <empty>');
    } else if (data is Map || data is List) {
      try {
        final jsonString = const JsonEncoder.withIndent('  ').convert(data);
        final lines = jsonString.split('\n');
        for (var line in lines) {
          buffer.writeln('│     $line');
        }
      } catch (_) {
        buffer.writeln('│     $data');
      }
    } else if (data is FormData) {
      buffer.writeln('│     [FormData]');
      for (var field in data.fields) {
        buffer.writeln('│       ${field.key}: ${field.value}');
      }
      for (var file in data.files) {
        buffer.writeln('│       ${file.key}: [File] ${file.value.filename}');
      }
    } else {
      buffer.writeln('│     $data');
    }
    
    buffer.writeln('├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄');
    
    final statusCode = response?.statusCode ?? error?.response?.statusCode ?? -1;
    buffer.writeln('│  ━━  RESPONSE  $statusCode');
    buffer.writeln('│');
    buffer.writeln('│  📄  BODY');
    
    final resData = response?.data ?? error?.response?.data;
    if (resData == null) {
      buffer.writeln('│     <empty>');
    } else if (resData is Map || resData is List) {
      try {
        final jsonString = const JsonEncoder.withIndent('  ').convert(resData);
        final lines = jsonString.split('\n');
        for (var line in lines) {
          buffer.writeln('│     $line');
        }
      } catch (_) {
        buffer.writeln('│     $resData');
      }
    } else {
      buffer.writeln('│     $resData');
    }
    
    buffer.writeln('└────────────────────────────────────────────────────────────────────────');
    
    debugPrint(buffer.toString());
  }
}

/// ===========================================================================
///                   CONNECTIVITY STREAM SERVICE (Global Subscriber)
/// ===========================================================================
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._internal();
  factory ConnectivityService() => instance;

  final Connectivity connectivity = Connectivity();
  final ValueNotifier<bool> isOnline = ValueNotifier(true);

  ConnectivityService._internal() {
    init();
  }

  void init() {
    // Initial check
    connectivity.checkConnectivity().then((resultList) {
      updateStatus(resultList);
    });

    // Listen to connection changes
    connectivity.onConnectivityChanged.listen((resultList) {
      updateStatus(resultList);
    });
  }

  void updateStatus(List<ConnectivityResult> results) {
    final connected =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);

    if (connected != isOnline.value) {
      isOnline.value = connected;

      showSnack(
        content: connected ? "Back Online" : "No Internet Connection",
        status: connected
            ? SnackBarStatus.connected
            : SnackBarStatus.disconnected,
      );
    }
  }

  void dispose() {
    isOnline.dispose();
  }
}

/// ===========================================================================
///                AUTH TOKEN SERVICE using GetStorage
/// ===========================================================================
class AuthTokenService {
  final GetStorage storage = GetStorage();

  static const String sessionTokenKey = 'session_token';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  String? get sessionToken => storage.read<String>(sessionTokenKey);
  String? get accessToken => storage.read<String>(accessTokenKey);
  String? get refreshToken => storage.read<String>(refreshTokenKey);

  void setSessionToken(String token) => storage.write(sessionTokenKey, token);
  void setAccessToken(String token) => storage.write(accessTokenKey, token);
  void setRefreshToken(String token) => storage.write(refreshTokenKey, token);

  void setTokens({
    required String sessionToken,
    required String accessToken,
    required String refreshToken,
  }) {
    setSessionToken(sessionToken);
    setAccessToken(accessToken);
    setRefreshToken(refreshToken);
  }

  void clearTokens() {
    storage.remove(sessionTokenKey);
    storage.remove(accessTokenKey);
    storage.remove(refreshTokenKey);
  }

  void logOut() {
    LoggerService().info('[AuthTokenService] Logging out...');
    clearTokens();
    Get.offAllNamed(AppRoutes.appRoot);
  }
}

/// ===========================================================================
///                            API SERVICE
/// ===========================================================================
enum ApiType { public, private }

class ApiService {
  static final ApiService instance = ApiService.internal();

  factory ApiService() => instance;

  late final Dio publicClient;
  late final Dio privateClient;
  final AuthTokenService authStorage = AuthTokenService();
  final LoggerService logger = LoggerService();

  ApiService.internal() {
    publicClient = createDioClient();
    privateClient = createDioClient();
    setupPublicInterceptors();
    setupPrivateInterceptors();
  }

  Dio createDioClient() {
    return Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  Dio getClient(ApiType apiType, [String? overrideBaseUrl]) {
    final base = apiType == ApiType.public ? publicClient : privateClient;
    if (overrideBaseUrl != null && overrideBaseUrl.isNotEmpty) {
      final newClient = Dio(base.options.copyWith(baseUrl: overrideBaseUrl));
      newClient.interceptors.addAll(base.interceptors);
      return newClient;
    }
    return base;
  }

  /// =========================================================================
  ///                     PUBLIC CLIENT INTERCEPTORS
  /// =========================================================================
  void setupPublicInterceptors() {
    publicClient.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          logger.logApi(requestOptions: response.requestOptions, response: response);
          handler.next(response);
        },
        onError: (e, handler) {
          logger.logApi(requestOptions: e.requestOptions, error: e);
          if (e.type == DioExceptionType.connectionError ||
              e.message?.toLowerCase().contains('failed host lookup') == true) {
            logger.error('[PUBLIC API ERROR] Connection Error');
            showSnack(
              content: 'Check your internet or try again later',
              status: SnackBarStatus.error,
            );
          } else {
            logger.error('[PUBLIC API ERROR] ${e.message}');
            showSnack(
              content: 'Something went wrong. Please try again.',
              status: SnackBarStatus.error,
            );
          }
          handler.next(e);
        },
      ),
    ]);
  }

  /// =========================================================================
  ///                     PRIVATE CLIENT INTERCEPTORS
  /// =========================================================================
  void setupPrivateInterceptors() {
    privateClient.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authStorage.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          logger.logApi(requestOptions: response.requestOptions, response: response);
          if (response.statusCode == 401 ||
              (response.statusCode == 403 &&
                  isUnauthorizedError(response.data))) {
            logger.error('[PRIVATE API] Unauthorized response. Logging out.');
            AuthTokenService().logOut();
          }
          handler.next(response);
        },
        onError: (e, handler) {
          logger.logApi(requestOptions: e.requestOptions, error: e);
          if (e.response?.statusCode == 401 ||
              (e.response?.statusCode == 403 &&
                  isUnauthorizedError(e.response?.data))) {
            logger.error(
              '[PRIVATE API ERROR] Unauthorized (onError). Logging out.',
            );
            AuthTokenService().logOut();
          }

          if (e.type == DioExceptionType.connectionError ||
              e.message?.toLowerCase().contains('failed host lookup') == true) {
            logger.error('[PRIVATE API ERROR] Connection Error: ${e.message}');
            showSnack(
              content: 'Check your internet or try again later',
              status: SnackBarStatus.disconnected,
            );
          } else {
            logger.error('[PRIVATE API ERROR] ${e.message}');
          }
          handler.next(e);
        },
      ),
    ]);
  }

  static bool isUnauthorizedError(dynamic data) {
    if (data is Map && data['error'] == 'Unauthorized') return true;
    return false;
  }

  void handleError(Response response) {
    final status = response.statusCode ?? 0;
    if (status >= 400) {
      final data = response.data;
      String message = 'Unexpected error';

      if (data is Map<String, dynamic>) {
        message =
            data['message']?.toString() ??
            data['error']?.toString() ??
            (data['errors'] is Map
                ? (data['errors'] as Map).values.first?.first?.toString() ??
                      'Invalid data'
                : 'Something went wrong');
      } else if (data != null) {
        message = data.toString();
      }

      throw AppException(message, statusCode: status, body: data);
    }
  }

  /// =========================================================================
  ///                              HTTP METHODS
  /// =========================================================================
  Future<Response> get(
    String path, {
    Map<String, dynamic>? query,
    ApiType apiType = ApiType.private,
    String? overrideBaseUrl,
    Map<String, dynamic>? headers,
  }) async {
    final client = getClient(apiType, overrideBaseUrl);
    final options = Options(
      headers: headers != null
          ? {...client.options.headers, ...headers}
          : client.options.headers,
    );

    final response = await client.get(
      path,
      queryParameters: query,
      options: options,
    );
    handleError(response);
    return response;
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    ApiType apiType = ApiType.private,
    String? overrideBaseUrl,
    Map<String, dynamic>? headers,
  }) async {
    final client = getClient(apiType, overrideBaseUrl);
    final options = Options(
      headers: headers != null
          ? {...client.options.headers, ...headers}
          : client.options.headers,
    );

    final response = await client.post(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
    handleError(response);
    return response;
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    ApiType apiType = ApiType.private,
    String? overrideBaseUrl,
    Map<String, dynamic>? headers,
  }) async {
    final client = getClient(apiType, overrideBaseUrl);
    final options = Options(
      headers: headers != null
          ? {...client.options.headers, ...headers}
          : client.options.headers,
    );

    final response = await client.patch(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
    handleError(response);
    return response;
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    ApiType apiType = ApiType.private,
    String? overrideBaseUrl,
    Map<String, dynamic>? headers,
  }) async {
    final client = getClient(apiType, overrideBaseUrl);
    final options = Options(
      headers: headers != null
          ? {...client.options.headers, ...headers}
          : client.options.headers,
    );

    final response = await client.put(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
    handleError(response);
    return response;
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    ApiType apiType = ApiType.private,
    String? overrideBaseUrl,
    Map<String, dynamic>? headers,
  }) async {
    final client = getClient(apiType, overrideBaseUrl);
    final options = Options(
      headers: headers != null
          ? {...client.options.headers, ...headers}
          : client.options.headers,
    );

    final response = await client.delete(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
    handleError(response);
    return response;
  }
}
