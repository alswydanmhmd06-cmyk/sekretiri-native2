import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../domain/doctor_ad.dart';

/// Public promotional doctor ads (no auth required). The endpoint always
/// returns `{ads: []}` on failure, so this never breaks the welcome screen.
final adsProvider = FutureProvider.autoDispose<List<DoctorAd>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final r = await api.dio.get('/api/ads');
    final list = r.data is Map ? r.data['ads'] : null;
    return list is List
        ? list
              .whereType<Map>()
              .map((e) => DoctorAd.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const <DoctorAd>[];
  } catch (_) {
    return const <DoctorAd>[];
  }
});
