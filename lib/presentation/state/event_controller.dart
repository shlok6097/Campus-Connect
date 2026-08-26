import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';
import '../../data/models/registration_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mock_repository.dart';

class EventController extends ChangeNotifier {
  static final EventController instance = EventController._internal();
  EventController._internal();

  final MockRepository _repo = MockRepository.instance;

  EventCategory? _selectedCategory;
  String _searchQuery = '';

  EventCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<EventModel> get allEvents => _repo.events;

  List<EventModel> get filteredEvents {
    return _repo.events.where((event) {
      final matchesCat = _selectedCategory == null || event.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.organizerName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  EventModel? get featuredEvent {
    return _repo.events.firstWhere((e) => e.isFeatured, orElse: () => _repo.events.first);
  }

  List<RegistrationModel> get allRegistrations => _repo.registrations;

  List<RegistrationModel> getRegistrationsForEvent(String eventId) {
    return _repo.registrations.where((r) => r.eventId == eventId).toList();
  }

  bool isUserRegistered(String eventId, String studentUSN) {
    return _repo.registrations.any((r) => r.eventId == eventId && r.studentUSN == studentUSN);
  }

  void setCategoryFilter(EventCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void registerForEvent({
    required EventModel event,
    required UserModel user,
    required Map<String, dynamic> customResponses,
  }) {
    final registration = RegistrationModel(
      id: 'REG-2026-${_repo.registrations.length + 1001}',
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
      customResponses: customResponses,
    );

    _repo.addRegistration(registration);
    notifyListeners();
  }

  void createEvent(EventModel newEvent) {
    _repo.addEvent(newEvent);
    notifyListeners();
  }

  void updateRegistrationStatus(String regId, RegistrationStatus newStatus) {
    final index = _repo.registrations.indexWhere((r) => r.id == regId);
    if (index != -1) {
      _repo.registrations[index] = _repo.registrations[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}
