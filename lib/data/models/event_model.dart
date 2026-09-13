enum EventCategory { technical, cultural, sports, workshop, hackathon, competition, others }

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'type': type.name,
    'is_required': isRequired,
    'options': options,
  };

  factory CustomFormField.fromJson(Map<String, dynamic> json) => CustomFormField(
    id: json['id'] as String? ?? '',
    label: json['label'] as String? ?? '',
    type: QuestionType.values.firstWhere(
      (t) => t.name.toLowerCase() == (json['type'] as String? ?? '').toLowerCase(),
      orElse: () => QuestionType.text,
    ),
    isRequired: json['is_required'] as bool? ?? json['isRequired'] as bool? ?? true,
    options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
  );
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

  Map<String, dynamic> toJson() => {
    'rank_title': rankTitle,
    'amount': amount,
    'description': description,
    'icon': icon,
  };

  factory PrizeItem.fromJson(Map<String, dynamic> json) => PrizeItem(
    rankTitle: json['rank_title'] as String? ?? json['rankTitle'] as String? ?? '',
    amount: json['amount'] as String? ?? '',
    description: json['description'] as String? ?? '',
    icon: json['icon'] as String? ?? 'trophy',
  );
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'time': time,
    'description': description,
    'is_completed': isCompleted,
  };

  factory TimelineStep.fromJson(Map<String, dynamic> json) => TimelineStep(
    title: json['title'] as String? ?? '',
    time: json['time'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isCompleted: json['is_completed'] as bool? ?? json['isCompleted'] as bool? ?? false,
  );
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final String? customCategory;
  final String bannerUrl;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? registrationDeadline;
  final String timeString; // e.g. "9:00 AM - 6:00 PM"
  final String venue;
  final String organizerName;
  final int maxParticipants;
  final int registeredCount;
  final double entryFee;
  final String? paymentUpiId;
  final String? tagline;
  final int teamMinSize;
  final int teamMaxSize;
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
    this.customCategory,
    required this.bannerUrl,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    required this.timeString,
    required this.venue,
    required this.organizerName,
    required this.maxParticipants,
    this.registeredCount = 0,
    this.entryFee = 0.0,
    this.paymentUpiId,
    this.tagline,
    this.teamMinSize = 1,
    this.teamMaxSize = 4,
    this.isFeatured = false,
    this.isPublished = true,
    this.prizes = const [],
    this.timeline = const [],
    this.rules = const [],
    this.eligibility = const [],
    this.customFormFields = const [],
  });

  bool get isPaid => entryFee > 0;
  bool get isFull => maxParticipants > 0 && registeredCount >= maxParticipants;
  int get availableSeats => maxParticipants > 0 ? (maxParticipants - registeredCount).clamp(0, maxParticipants) : 999;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      if (customCategory != null) 'custom_category': customCategory,
      'banner_url': bannerUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      if (registrationDeadline != null) 'registration_deadline': registrationDeadline!.toIso8601String(),
      'time_string': timeString,
      'venue': venue,
      'organizer_name': organizerName,
      'max_participants': maxParticipants,
      'registered_count': registeredCount,
      'entry_fee': entryFee,
      if (paymentUpiId != null) 'payment_upi_id': paymentUpiId,
      if (tagline != null) 'tagline': tagline,
      'team_min_size': teamMinSize,
      'team_max_size': teamMaxSize,
      'is_featured': isFeatured,
      'is_published': isPublished,
      'prizes': prizes.map((p) => p.toJson()).toList(),
      'timeline': timeline.map((t) => t.toJson()).toList(),
      'rules': rules,
      'eligibility': eligibility,
      'custom_form_fields': customFormFields.map((f) => f.toJson()).toList(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: EventCategory.values.firstWhere(
        (c) => c.name.toLowerCase() == (json['category'] as String? ?? '').toLowerCase(),
        orElse: () => EventCategory.workshop,
      ),
      customCategory: json['custom_category'] as String? ?? json['customCategory'] as String?,
      bannerUrl: json['banner_url'] as String? ?? json['bannerUrl'] as String? ?? '',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.tryParse(json['registration_deadline'].toString())
          : null,
      timeString: json['time_string'] as String? ?? json['timeString'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      organizerName: json['organizer_name'] as String? ?? json['organizerName'] as String? ?? '',
      maxParticipants: json['max_participants'] as int? ?? (json['maxParticipants'] as num?)?.toInt() ?? 0,
      registeredCount: json['registered_count'] as int? ?? (json['registeredCount'] as num?)?.toInt() ?? 0,
      entryFee: (json['entry_fee'] as num?)?.toDouble() ?? (json['entryFee'] as num?)?.toDouble() ?? 0.0,
      paymentUpiId: json['payment_upi_id'] as String? ?? json['paymentUpiId'] as String?,
      tagline: json['tagline'] as String?,
      teamMinSize: json['team_min_size'] as int? ?? 1,
      teamMaxSize: json['team_max_size'] as int? ?? 4,
      isFeatured: json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? json['isPublished'] as bool? ?? true,
      prizes: (json['prizes'] as List<dynamic>?)
              ?.map((p) => PrizeItem.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((t) => TimelineStep.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      rules: (json['rules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      eligibility: (json['eligibility'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      customFormFields: (json['custom_form_fields'] as List<dynamic>?)
              ?.map((f) => CustomFormField.fromJson(f as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    String? customCategory,
    String? bannerUrl,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    String? timeString,
    String? venue,
    String? organizerName,
    int? maxParticipants,
    int? registeredCount,
    double? entryFee,
    String? paymentUpiId,
    String? tagline,
    int? teamMinSize,
    int? teamMaxSize,
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
      customCategory: customCategory ?? this.customCategory,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      timeString: timeString ?? this.timeString,
      venue: venue ?? this.venue,
      organizerName: organizerName ?? this.organizerName,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredCount: registeredCount ?? this.registeredCount,
      entryFee: entryFee ?? this.entryFee,
      paymentUpiId: paymentUpiId ?? this.paymentUpiId,
      tagline: tagline ?? this.tagline,
      teamMinSize: teamMinSize ?? this.teamMinSize,
      teamMaxSize: teamMaxSize ?? this.teamMaxSize,
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

class EventUpdateModel {
  final String id;
  final String eventId;
  final String title;
  final String message;
  final DateTime createdAt;

  const EventUpdateModel({
    required this.id,
    required this.eventId,
    required this.title,
    this.message = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'event_id': eventId,
    'title': title,
    'message': message,
    'created_at': createdAt.toIso8601String(),
  };

  factory EventUpdateModel.fromJson(Map<String, dynamic> json) => EventUpdateModel(
    id: json['id'] as String? ?? '',
    eventId: json['event_id'] as String? ?? json['eventId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
  );
}

class EventNotificationModel {
  final String id;
  final String eventId;
  final String title;
  final String message;
  final String recipientGroup; // 'all', 'confirmed', 'pending'
  final String? sentByUserId;
  final DateTime createdAt;

  const EventNotificationModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.message,
    this.recipientGroup = 'all',
    this.sentByUserId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'event_id': eventId,
    'title': title,
    'message': message,
    'recipient_group': recipientGroup,
    'sent_by_user_id': sentByUserId,
    'created_at': createdAt.toIso8601String(),
  };

  factory EventNotificationModel.fromJson(Map<String, dynamic> json) => EventNotificationModel(
    id: json['id'] as String? ?? '',
    eventId: json['event_id'] as String? ?? json['eventId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
    recipientGroup: json['recipient_group'] as String? ?? json['recipientGroup'] as String? ?? 'all',
    sentByUserId: json['sent_by_user_id'] as String? ?? json['sentByUserId'] as String?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
  );
}
