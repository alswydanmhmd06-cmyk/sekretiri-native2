class Appointment {
  const Appointment({required this.id, required this.queueNumber, required this.status, required this.date, this.patientName, this.patientPhone, this.doctorName, this.doctorSpecialty, this.patientsAhead = 0});
  final int id;
  final int queueNumber;
  final String status;
  final String date;
  final String? patientName;
  final String? patientPhone;
  final String? doctorName;
  final String? doctorSpecialty;
  final int patientsAhead;
  factory Appointment.fromJson(Map<String,dynamic> j) => Appointment(
    id: _i(j['id']) ?? 0, queueNumber: _i(j['queueNumber']) ?? 0,
    status: j['status']?.toString() ?? 'waiting', date: j['appointmentDate']?.toString() ?? '',
    patientName: j['patientName']?.toString(), patientPhone: j['patientPhone']?.toString(),
    doctorName: j['doctorName']?.toString(), doctorSpecialty: j['doctorSpecialty']?.toString(),
    patientsAhead: _i(j['patientsAhead']) ?? 0,
  );
}
class DoctorCardData {
  const DoctorCardData({required this.id, required this.name, required this.specialty, required this.address, required this.phone, required this.fee, this.photoUrl, this.rating = 0, this.ratingCount = 0, this.present = true});
  final int id; final String name; final String specialty; final String address; final String phone; final num fee; final String? photoUrl; final num rating; final int ratingCount; final bool present;
  factory DoctorCardData.fromJson(Map<String,dynamic> j) => DoctorCardData(
    id: _i(j['id']) ?? 0, name: j['fullName']?.toString() ?? '', specialty: j['specialty']?.toString() ?? '',
    address: j['clinicAddress']?.toString() ?? '', phone: j['phone']?.toString() ?? '', fee: j['consultationFee'] is num ? j['consultationFee'] as num : num.tryParse('${j['consultationFee']}') ?? 0,
    photoUrl: j['photoUrl']?.toString(), rating: j['averageRating'] is num ? j['averageRating'] as num : 0,
    ratingCount: _i(j['ratingCount']) ?? 0, present: j['isPresent'] == true,
  );
}
int? _i(Object? v) => v is int ? v : int.tryParse('$v');
