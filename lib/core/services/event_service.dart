import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/event_model.dart';
import '../../data/models/registration_model.dart';
import 'supabase_service.dart';

class EventService {
  static final EventService instance = EventService._internal();
  EventService._internal();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Upload device poster image to Supabase Storage
  Future<String?> uploadEventPoster(Uint8List bytes, String fileName) async {
    try {
      final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = '${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
      await _client.storage.from('event-posters').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      final publicUrl = _client.storage.from('event-posters').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      // Fallback to Data URI so offline / permission errors still work seamlessly
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    }
  }

  /// Fetch all published events from Supabase
  Future<List<EventModel>> fetchEvents() async {
    try {
      final response = await _client
          .from('events')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => EventModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Return empty list if table empty or network offline
      return [];
    }
  }

  /// Create and persist a new event to Supabase
  Future<bool> createEvent(EventModel event) async {
    try {
      await _client.from('events').insert(event.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Submit student response / registration for an event
  Future<bool> registerForEvent(RegistrationModel registration) async {
    try {
      await _client.from('event_registrations').insert(registration.toJson());

      // Increment registered_count on the event
      try {
        final eventData = await _client
            .from('events')
            .select('registered_count')
            .eq('id', registration.eventId)
            .maybeSingle();

        if (eventData != null) {
          final currentCount = (eventData['registered_count'] as num?)?.toInt() ?? 0;
          await _client
              .from('events')
              .update({'registered_count': currentCount + 1})
              .eq('id', registration.eventId);
        }
      } catch (_) {}

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch student registrations / responses for an event or student
  Future<List<RegistrationModel>> fetchRegistrations({
    String? eventId,
    String? studentId,
  }) async {
    try {
      var query = _client.from('event_registrations').select();

      if (eventId != null && eventId.isNotEmpty) {
        query = query.eq('event_id', eventId);
      }
      if (studentId != null && studentId.isNotEmpty) {
        query = query.eq('student_id', studentId);
      }

      final response = await query.order('registration_date', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => RegistrationModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update registration status (confirmed, waitlisted, rejected, checkedIn)
  Future<bool> updateRegistrationStatus(String regId, RegistrationStatus status) async {
    try {
      await _client
          .from('event_registrations')
          .update({'status': status.name})
          .eq('id', regId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update payment status (verified, pending, rejected)
  Future<bool> updatePaymentStatus(String regId, String paymentStatus) async {
    try {
      await _client
          .from('event_registrations')
          .update({'payment_status': paymentStatus})
          .eq('id', regId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update an existing event in Supabase
  Future<bool> updateEvent(EventModel event) async {
    try {
      await _client.from('events').update(event.toJson()).eq('id', event.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch recent updates / announcements for an event
  Future<List<EventUpdateModel>> fetchEventUpdates(String eventId) async {
    try {
      final response = await _client
          .from('event_updates')
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => EventUpdateModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Post a new update / announcement for an event
  Future<bool> createEventUpdate(EventUpdateModel update) async {
    try {
      await _client.from('event_updates').insert(update.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete an announcement/update for an event
  Future<bool> deleteEventUpdate(String updateId) async {
    try {
      await _client.from('event_updates').delete().eq('id', updateId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send / record a notification to event participants
  Future<bool> sendEventNotification(EventNotificationModel notification) async {
    try {
      await _client.from('event_notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch notifications sent for an event
  Future<List<EventNotificationModel>> fetchEventNotifications(String eventId) async {
    try {
      final response = await _client
          .from('event_notifications')
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => EventNotificationModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
}
