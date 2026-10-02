import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores cookie-jar records in the platform secure store, not in plain files.
/// The prefix keeps cookie records separate from the cached profile entry.
class SecureCookieStorage implements Storage {
  SecureCookieStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  static const _prefix = 'sekretiri.cookie.';

  String _key(String key) => '$_prefix$key';

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    // Secure storage is initialized by its platform plugin on first access.
  }

  @override
  Future<String?> read(String key) => _secureStorage.read(key: _key(key));

  @override
  Future<void> write(String key, String value) =>
      _secureStorage.write(key: _key(key), value: value);

  @override
  Future<void> delete(String key) => _secureStorage.delete(key: _key(key));

  @override
  Future<void> deleteAll(List<String> keys) async {
    // Do not call secureStorage.deleteAll(): it could erase unrelated secrets.
    for (final key in keys) {
      await delete(key);
    }
  }
}
