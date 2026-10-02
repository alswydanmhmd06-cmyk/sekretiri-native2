import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

final apiClientProvider = Provider<ApiClient>(
  (ref) => throw StateError('ApiClient لم تتم تهيئته في main.dart.'),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final authProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  late AuthRepository _repository;

  @override
  Future<AppUser?> build() {
    _repository = ref.watch(authRepositoryProvider);
    return _repository.restoreCachedUser();
  }

  Future<void> signIn({
    required String email,
    required String password,
    required String accountType,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => _repository.signIn(
        email: email,
        password: password,
        accountType: accountType,
      ),
    );
    if (result.hasError) {
      final error = result.error!;
      final stackTrace = result.stackTrace!;
      state = const AsyncData(null);
      Error.throwWithStackTrace(error, stackTrace);
    }
    state = result;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _repository.signOut();
    state = const AsyncData(null);
  }
}
