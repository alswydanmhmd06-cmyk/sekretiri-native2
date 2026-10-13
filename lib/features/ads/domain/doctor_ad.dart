/// Promotional doctor card shown on the welcome screen carousel.
/// Source: GET /api/ads → {ads:[{photoUrl(base64 dataURL), doctorName, ...}]}.
class DoctorAd {
  const DoctorAd({
    required this.id,
    required this.doctorName,
    this.photoUrl,
    this.specialty,
    this.clinicName,
    this.clinicAddress,
    this.phone,
    this.rating,
    this.appointmentsCount,
    this.description,
  });

  final int id;
  final String doctorName;

  /// Usually a base64 `data:image/...` URL. May also be a remote http(s) URL.
  final String? photoUrl;
  final String? specialty;
  final String? clinicName;
  final String? clinicAddress;
  final String? phone;
  final String? rating; // free text in the web schema
  final int? appointmentsCount;
  final String? description;

  factory DoctorAd.fromJson(Map<String, dynamic> j) => DoctorAd(
    id: _i(j['id']) ?? 0,
    doctorName: j['doctorName']?.toString() ?? '',
    photoUrl: (j['photoUrl'] == null || '${j['photoUrl']}'.isEmpty)
        ? null
        : j['photoUrl'].toString(),
    specialty: j['specialty']?.toString(),
    clinicName: j['clinicName']?.toString(),
    clinicAddress: j['clinicAddress']?.toString(),
    phone: j['phone']?.toString(),
    rating: (j['rating'] == null || '${j['rating']}'.isEmpty)
        ? null
        : j['rating'].toString(),
    appointmentsCount: _i(j['appointmentsCount']),
    description: j['description']?.toString(),
  );
}

int? _i(Object? v) => v is int ? v : int.tryParse('$v');
