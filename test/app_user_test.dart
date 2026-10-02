import 'package:flutter_test/flutter_test.dart';
import 'package:sekretiri_flutter/features/auth/domain/app_user.dart';

void main() {
  group('AppUser.fromJson', () {
    test('parses a patient account', () {
      final user = AppUser.fromJson({
        'id': 12,
        'fullName': 'مريض تجريبي',
        'email': 'patient@example.test',
        'type': 'patient',
      });

      expect(user.isPatient, isTrue);
      expect(user.isDoctorOrSecretary, isFalse);
      expect(user.fullName, 'مريض تجريبي');
    });

    test('keeps the doctor identity and secretary role returned by API', () {
      final user = AppUser.fromJson({
        'id': 4,
        'doctorId': 4,
        'fullName': 'سكرتير تجريبي',
        'email': 'secretary@example.test',
        'type': 'doctor',
        'role': 'secretary',
        'isPaid': true,
        'subscriptionActive': true,
      });

      expect(user.isDoctorOrSecretary, isTrue);
      expect(user.isSecretary, isTrue);
      expect(user.doctorId, 4);
      expect(user.subscriptionActive, isTrue);
    });

    test('rejects an unrecognized account type', () {
      expect(
        () => AppUser.fromJson({'id': 1, 'type': 'admin'}),
        throwsFormatException,
      );
    });
  });
}
