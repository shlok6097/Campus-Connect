import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  static const String _defaultUrl = 'https://fkqmxtmzacurnxoprvzw.supabase.co';
  static const String _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZrcW14dG16YWN1cm54b3Bydnp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3MTMwNTEsImV4cCI6MjEwMzI4OTA1MX0.YybGsw7twj08JjGEQYqlgp1tQOFOXOELpu1BgOGz1T4';

  bool _initialized = false;

  bool get isInitialized => _initialized;

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;
  User? get currentAuthUser => auth.currentUser;
  Session? get currentSession => auth.currentSession;

  static Future<void> initialize() async {
    if (instance._initialized) return;

    String url = _defaultUrl;
    String anonKey = _defaultAnonKey;

    try {
      await dotenv.load(fileName: '.env');
      url = dotenv.env['SUPABASE_URL']?.trim() ?? _defaultUrl;
      anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? _defaultAnonKey;
    } catch (_) {
      // Fallback to configured defaults if .env is missing or not readable
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      instance._initialized = true;
    } catch (_) {
      // If already initialized or during test harness
      instance._initialized = true;
    }
  }
}
