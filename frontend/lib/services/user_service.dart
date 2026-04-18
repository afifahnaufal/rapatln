import 'package:rapatln_tb/core/dio_client.dart';
import 'package:rapatln_tb/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class UserService {
  final Dio _dio = DioClient.dio;
  static const String _userKey = 'user_id';

  // Cache the ID in memory for faster access
  static String? currentUserId;

  // Initialize and load saved user ID
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString(_userKey);
  }

  Future<void> register(String username, String password, String name) async {
    try {
      await _dio.post(
        '/register',
        data: {'username': username, 'password': password, 'name': name},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      final user = User.fromJson(response.data['data']);

      // Save ID to SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, user.id!);
      currentUserId = user.id;

      return user;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    currentUserId = null;
  }

  Future<User> getUserProfile() async {
    // If memory cache is null, try to load from status (should be called after init)
    if (currentUserId == null) {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString(_userKey);
    }

    if (currentUserId == null) throw Exception('Not logged in');

    try {
      final response = await _dio.get('/user/$currentUserId');
      return User.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUserProfile(User user) async {
    if (currentUserId == null) throw Exception('Not logged in');
    try {
      // Cek apakah ada file profil baru (path lokal)
      bool isLocalFile =
          user.profileImagePath != null &&
          user.profileImagePath!.isNotEmpty &&
          !user.profileImagePath!.startsWith('http') &&
          File(user.profileImagePath!).existsSync();

      if (isLocalFile) {
        // Upload dengan FormData (multipart) - build properly
        final file = File(user.profileImagePath!);
        // Extract filename dengan split path
        final fileName = file.path.split(Platform.pathSeparator).last;

        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );

        final formData = FormData();
        formData.fields.add(MapEntry('id', user.id ?? ''));
        formData.fields.add(MapEntry('name', user.name));
        formData.fields.add(MapEntry('position', user.position));
        formData.fields.add(MapEntry('bio', user.bio));
        formData.files.add(MapEntry('profileImage', multipartFile));

        print('DEBUG: Uploading file with name: $fileName');
        print('DEBUG: File size: ${file.lengthSync()} bytes');

        final response = await _dio.put('/user/$currentUserId', data: formData);
        print('DEBUG: Upload response: $response');
      } else {
        // Kirim data tanpa file (JSON biasa)
        print('DEBUG: Sending JSON without file');
        await _dio.put('/user/$currentUserId', data: user.toJson());
      }
      return user;
    } on DioException catch (e) {
      print('DEBUG: DioException - ${e.type} - ${e.message}');
      print('DEBUG: Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('DEBUG: Exception - $e');
      rethrow;
    }
  }
}
