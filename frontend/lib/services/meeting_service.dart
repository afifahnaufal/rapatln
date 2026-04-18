import 'package:rapatln_tb/core/dio_client.dart';
import 'package:rapatln_tb/models/meeting_model.dart';
import 'package:dio/dio.dart';

class MeetingService {
  final Dio _dio = DioClient.dio;

  Future<List<Meeting>> getAllMeetings() async {
    try {
      final response = await _dio.get('/meetings');
      final List data = response.data['data'];
      return data.map((e) => Meeting.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Meeting> getMeetingById(String id) async {
    try {
      final response = await _dio.get('/meetings/$id');
      return Meeting.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Meeting> createMeeting(Meeting meeting) async {
    try {
      final response = await _dio.post('/meetings', data: meeting.toJson());
      return Meeting.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Meeting> updateMeeting(String id, Meeting meeting) async {
    try {
      final response = await _dio.patch(
        '/meetings/$id',
        data: meeting.toJson(),
      );
      return Meeting.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeeting(String id) async {
    try {
      await _dio.delete('/meetings/$id');
    } catch (e) {
      rethrow;
    }
  }
}
