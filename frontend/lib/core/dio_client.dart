import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  // Gunakan localhost untuk Web/Desktop, dan 10.0.2.2 untuk Emulator Android
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    return 'http://10.0.2.2:8080/api';
  }

  static Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
