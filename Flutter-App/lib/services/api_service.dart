import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com/api', // replace with actual backend URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth tokens here if available
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Handle retry mechanism or logging
        return handler.next(e);
      },
    ));
  }

  Future<Response> postPaymentData(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/payments', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getTransactions(int page) async {
    try {
      final response = await _dio.get('/transactions', queryParameters: {'page': page});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
