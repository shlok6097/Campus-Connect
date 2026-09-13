import 'dart:convert';
import '../../data/models/auth_session_model.dart';

abstract class SessionStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }
}

class SessionService {
  static final SessionService instance = SessionService._internal();

  SessionStorage _storage = InMemorySessionStorage();
  AuthSession? _activeSession;

  static const String _sessionKey = 'cc_auth_session_v1';

  SessionService._internal();

  void setStorage(SessionStorage storage) {
    _storage = storage;
  }

  AuthSession? get currentSession => _activeSession;

  bool get hasValidSession => _activeSession != null && _activeSession!.isValid;

  Future<void> saveSession(AuthSession session) async {
    _activeSession = session;
    try {
      final jsonStr = jsonEncode(session.toJson());
      await _storage.write(_sessionKey, jsonStr);
    } catch (_) {
      // In-memory fallback is still active
    }
  }

  Future<AuthSession?> loadSession() async {
    if (_activeSession != null && _activeSession!.isValid) {
      return _activeSession;
    }

    try {
      final jsonStr = await _storage.read(_sessionKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        _activeSession = null;
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final session = AuthSession.fromJson(data);

      if (session.isExpired) {
        await clearSession();
        return null;
      }

      _activeSession = session;
      return session;
    } catch (_) {
      _activeSession = null;
      return null;
    }
  }

  Future<void> clearSession() async {
    _activeSession = null;
    try {
      await _storage.delete(_sessionKey);
    } catch (_) {
      // Ignore
    }
  }
}
