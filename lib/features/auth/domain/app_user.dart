class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.type,
    this.role,
    this.doctorId,
    this.isPaid,
    this.subscriptionEnd,
    this.subscriptionActive,
  });

  final int id;
  final String fullName;
  final String email;
  final String type;
  final String? role;
  final int? doctorId;
  final bool? isPaid;
  final DateTime? subscriptionEnd;
  final bool? subscriptionActive;

  bool get isPatient => type == 'patient';
  bool get isDoctorOrSecretary => type == 'doctor';
  bool get isSecretary => role == 'secretary';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = _readInt(json['id']);
    final type = json['type'];
    if (id == null ||
        type is! String ||
        !{'doctor', 'patient'}.contains(type)) {
      throw const FormatException(
        'بيانات المستخدم المستلمة من الخادم غير صالحة.',
      );
    }

    return AppUser(
      id: id,
      fullName: json['fullName'] is String ? json['fullName'] as String : '',
      email: json['email'] is String ? json['email'] as String : '',
      type: type,
      role: json['role'] is String ? json['role'] as String : null,
      doctorId: _readInt(json['doctorId']),
      isPaid: json['isPaid'] is bool ? json['isPaid'] as bool : null,
      subscriptionEnd: _readDate(json['subscriptionEnd']),
      subscriptionActive: json['subscriptionActive'] is bool
          ? json['subscriptionActive'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'type': type,
    if (role != null) 'role': role,
    if (doctorId != null) 'doctorId': doctorId,
    if (isPaid != null) 'isPaid': isPaid,
    if (subscriptionEnd != null)
      'subscriptionEnd': subscriptionEnd!.toIso8601String(),
    if (subscriptionActive != null) 'subscriptionActive': subscriptionActive,
  };

  static int? _readInt(Object? value) => switch (value) {
    int number => number,
    String text => int.tryParse(text),
    _ => null,
  };

  static DateTime? _readDate(Object? value) => switch (value) {
    DateTime date => date,
    String text => DateTime.tryParse(text),
    _ => null,
  };
}
