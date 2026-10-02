import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/models.dart';
import 'dashboard_repository.dart';
final dashboardRepositoryProvider = Provider((ref) => DashboardRepository(ref.watch(apiClientProvider)));
final appointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) => ref.watch(dashboardRepositoryProvider).appointments());
final doctorsProvider = FutureProvider.autoDispose<List<DoctorCardData>>((ref) => ref.watch(dashboardRepositoryProvider).doctors());
final prescriptionsProvider = FutureProvider.autoDispose<List<Map<String,dynamic>>>((ref) => ref.watch(dashboardRepositoryProvider).prescriptions());
