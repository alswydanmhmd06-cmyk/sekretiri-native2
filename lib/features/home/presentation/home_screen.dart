import 'package:flutter/material.dart';
import '../../auth/domain/app_user.dart';
import '../../dashboard/presentation/doctor_dashboard.dart';
import '../../dashboard/presentation/patient_dashboard.dart';
class HomeScreen extends StatelessWidget { const HomeScreen({required this.user,super.key}); final AppUser user; @override Widget build(BuildContext context){ if(user.isPatient) return PatientDashboard(user:user); return DoctorDashboard(user:user); } }
