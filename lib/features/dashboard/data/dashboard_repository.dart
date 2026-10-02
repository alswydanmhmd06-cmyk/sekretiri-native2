import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../domain/models.dart';

class DashboardRepository {
  DashboardRepository(this.api);
  final ApiClient api;
  Future<List<Appointment>> appointments() async {
    final r = await api.dio.get('/api/appointments');
    final list = r.data is Map ? r.data['appointments'] : null;
    return list is List ? list.whereType<Map>().map((e) => Appointment.fromJson(Map<String,dynamic>.from(e))).toList() : const [];
  }
  Future<List<DoctorCardData>> doctors({String search = ''}) async {
    final r = await api.dio.get('/api/doctors', queryParameters: {'search': search});
    final list = r.data is Map ? r.data['doctors'] : null;
    return list is List ? list.whereType<Map>().map((e) => DoctorCardData.fromJson(Map<String,dynamic>.from(e))).toList() : const [];
  }
  Future<List<Map<String,dynamic>>> prescriptions() async {
    final r = await api.dio.get('/api/prescriptions');
    final list = r.data is Map ? r.data['prescriptions'] : null;
    return list is List ? list.whereType<Map>().map((e) => Map<String,dynamic>.from(e)).toList() : const [];
  }
}
