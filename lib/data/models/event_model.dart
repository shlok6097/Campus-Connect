enum EventCategory { technical, cultural, sports, workshop, hackathon, competition }

enum QuestionType { text, multiline, dropdown, multipleChoice, checkbox }

class CustomFormField {
  final String id;
  final String label;
  final QuestionType type;
  final bool isRequired;
  final List<String> options;

  const CustomFormField({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = true,
    this.options = const [],
  });
}

class PrizeItem {
  final String rankTitle; // e.g. "1st Place", "2nd Place", "3rd Place"
  final String amount;    // e.g. "₹25,000"
  final String description;
  final String icon;

  const PrizeItem({
    required this.rankTitle,
    required this.amount,
    required this.description,
    this.icon = 'trophy',
  });
}

class TimelineStep {
  final String title;
  final String time;
  final String description;
  final bool isCompleted;

  const TimelineStep({
    required this.title,
    required this.time,
    this.description = '',
    this.isCompleted = false,
  });
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final String bannerUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String timeString; // e.g. "9:00 AM - 6:00 PM"
  final String venue;
  final String organizerName;
  final int maxParticipants;
  final int registeredCount;
  final double entryFee;
  final bool isFeatured;
  final bool isPublished;
  final List<PrizeItem> prizes;
  final List<TimelineStep> timeline;
  final List<String> rules;
  final List<String> eligibility;
  final List<CustomFormField> customFormFields;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.bannerUrl,
    required this.startDate,
    required this.endDate,
    required this.timeString,
    required this.venue,
    required this.organizerName,
    required this.maxParticipants,
    this.registeredCount = 0,
    this.entryFee = 0.0,
    this.isFeatured = false,
    this.isPublished = true,
    this.prizes = const [],
    this.timeline = const [],
    this.rules = const [],
    this.eligibility = const [],
    this.customFormFields = const [],
  });

  bool get isFull => registeredCount >= maxParticipants;
  int get availableSeats => (maxParticipants - registeredCount).clamp(0, maxParticipants);

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    String? bannerUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? timeString,
    String? venue,
    String? organizerName,
    int? maxParticipants,
    int? registeredCount,
    double? entryFee,
    bool? isFeatured,
    bool? isPublished,
    List<PrizeItem>? prizes,
    List<TimelineStep>? timeline,
    List<String>? rules,
    List<String>? eligibility,
    List<CustomFormField>? customFormFields,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timeString: timeString ?? this.timeString,
      venue: venue ?? this.venue,
      organizerName: organizerName ?? this.organizerName,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredCount: registeredCount ?? this.registeredCount,
      entryFee: entryFee ?? this.entryFee,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublished: isPublished ?? this.isPublished,
      prizes: prizes ?? this.prizes,
      timeline: timeline ?? this.timeline,
      rules: rules ?? this.rules,
      eligibility: eligibility ?? this.eligibility,
      customFormFields: customFormFields ?? this.customFormFields,
    );
  }
}
