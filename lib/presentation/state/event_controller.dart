import 'package:flutter/material.dart';
import '../../core/services/event_service.dart';
import '../../data/models/event_model.dart';
import '../../data/models/registration_model.dart';
import '../../data/models/user_model.dart';

class EventController extends ChangeNotifier {
  static final EventController instance = EventController._internal();
  EventController._internal() {
    loadEvents();
  }

  final EventService _service = EventService.instance;

  List<EventModel> _events = [];
  List<RegistrationModel> _registrations = [];
  bool _isLoading = false;

  EventCategory? _selectedCategory;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  EventCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<EventModel> get allEvents => _events;

  List<EventModel> get filteredEvents {
    return _events.where((event) {
      final matchesCat =
          _selectedCategory == null || event.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.organizerName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  EventModel? get featuredEvent {
    if (_events.isEmpty) return null;
    return _events.firstWhere((e) => e.isFeatured, orElse: () => _events.first);
  }

  List<RegistrationModel> get allRegistrations => _registrations;

  List<RegistrationModel> getRegistrationsForEvent(String eventId) {
    return _registrations.where((r) => r.eventId == eventId).toList();
  }

  bool isUserRegistered(String eventId, String studentUSN) {
    return _registrations.any(
      (r) =>
          r.eventId == eventId &&
          (r.studentUSN == studentUSN || r.studentId == studentUSN),
    );
  }

  void setCategoryFilter(EventCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Load real events & registrations from Supabase
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dbEvents = await _service.fetchEvents();
      final dbRegs = await _service.fetchRegistrations();

      _events = dbEvents;
      _registrations = dbRegs;
    } catch (_) {
      // Retain in-memory cache if offline
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register student response and persist to Supabase
  Future<bool> registerForEvent({
    required EventModel event,
    required UserModel user,
    required Map<String, dynamic> customResponses,
    String paymentStatus = 'free',
    String? paymentReference,
    double amount = 0.0,
  }) async {
    final registration = RegistrationModel(
      id: 'REG-2026-${_registrations.length + 1001}',
      eventId: event.id,
      eventTitle: event.title,
      studentId: user.id,
      studentUSN: user.studentId,
      studentName: user.name,
      studentEmail: user.email,
      studentPhone: user.phone,
      branch: user.branch,
      semester: user.semester,
      registrationDate: DateTime.now(),
      status: RegistrationStatus.confirmed,
      paymentStatus: paymentStatus,
      paymentReference: paymentReference,
      amount: amount,
      customResponses: customResponses,
    );

    // Optimistic local update
    _registrations.insert(0, registration);

    final eventIndex = _events.indexWhere((e) => e.id == event.id);
    if (eventIndex != -1) {
      _events[eventIndex] = _events[eventIndex].copyWith(
        registeredCount: _events[eventIndex].registeredCount + 1,
      );
    }
    notifyListeners();

    // Async persist to Supabase
    try {
      await _service.registerForEvent(registration);
    } catch (_) {}
    return true;
  }

  /// Create new event and persist to Supabase
  Future<bool> createEvent(EventModel newEvent) async {
    // Optimistic local update
    _events.insert(0, newEvent);
    notifyListeners();

    // Async persist to Supabase
    try {
      await _service.createEvent(newEvent);
    } catch (_) {}
    return true;
  }

  /// Get published events strictly belonging to a specific club/organizer
  List<EventModel> getClubPublishedEvents({String? clubName, String? clubId, String? userId}) {
    return _events.where((event) {
      final isPublished = event.isPublished;
      if (!isPublished) return false;

      if (clubName != null && clubName.trim().isNotEmpty) {
        final c1 = event.organizerName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
        final c2 = clubName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
        final matchesClubName = c1 == c2 || c1.contains(c2) || c2.contains(c1);
        if (matchesClubName) return true;
      }

      // If no specific club filter supplied, return all published events
      return clubName == null || clubName.trim().isEmpty;
    }).toList();
  }

  /// Update existing event and persist to Supabase
  Future<bool> updateEvent(EventModel updatedEvent) async {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }

    try {
      await _service.updateEvent(updatedEvent);
    } catch (_) {}
    return true;
  }

  /// Update attendee registration status
  Future<bool> updateRegistrationStatus(
    String regId,
    RegistrationStatus newStatus,
  ) async {
    final index = _registrations.indexWhere((r) => r.id == regId);
    if (index != -1) {
      _registrations[index] =
          _registrations[index].copyWith(status: newStatus);
      notifyListeners();
    }

    return await _service.updateRegistrationStatus(regId, newStatus);
  }

  /// Update payment verification status
  Future<bool> updatePaymentStatus(
    String regId,
    String paymentStatus,
  ) async {
    final index = _registrations.indexWhere((r) => r.id == regId);
    if (index != -1) {
      _registrations[index] =
          _registrations[index].copyWith(paymentStatus: paymentStatus);
      notifyListeners();
    }

    return await _service.updatePaymentStatus(regId, paymentStatus);
  }

  /// Fetch updates for an event
  Future<List<EventUpdateModel>> fetchEventUpdates(String eventId) async {
    return await _service.fetchEventUpdates(eventId);
  }

  /// Post a new update for an event
  Future<bool> createEventUpdate(EventUpdateModel update) async {
    return await _service.createEventUpdate(update);
  }

  /// Delete an event update
  Future<bool> deleteEventUpdate(String updateId) async {
    return await _service.deleteEventUpdate(updateId);
  }

  /// Send a notification to event participants
  Future<bool> sendEventNotification(EventNotificationModel notification) async {
    return await _service.sendEventNotification(notification);
  }

  /// Fetch notifications for an event
  Future<List<EventNotificationModel>> fetchEventNotifications(String eventId) async {
    return await _service.fetchEventNotifications(eventId);
  }
}
