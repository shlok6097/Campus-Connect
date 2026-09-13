enum RegistrationStatus { confirmed, pending, waitlisted, rejected }

class RegistrationModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String studentId; // User UID
  final String studentUSN;
  final String studentName;
  final String studentEmail;
  final String studentPhone;
  final String branch;
  final int semester;
  final DateTime registrationDate;
  final RegistrationStatus status;
  final String paymentStatus; // e.g. 'verified', 'pending', 'free'
  final String? paymentReference;
  final double amount;
  final Map<String, dynamic> customResponses;

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.studentId,
    required this.studentUSN,
    required this.studentName,
    required this.studentEmail,
    required this.studentPhone,
    required this.branch,
    required this.semester,
    required this.registrationDate,
    this.status = RegistrationStatus.confirmed,
    this.paymentStatus = 'free',
    this.paymentReference,
    this.amount = 0.0,
    this.customResponses = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'event_title': eventTitle,
      'student_id': studentId,
      'student_usn': studentUSN,
      'student_name': studentName,
      'student_email': studentEmail,
      'student_phone': studentPhone,
      'branch': branch,
      'semester': semester,
      'registration_date': registrationDate.toIso8601String(),
      'status': status.name,
      'payment_status': paymentStatus,
      if (paymentReference != null) 'payment_reference': paymentReference,
      'amount': amount,
      'custom_responses': customResponses,
    };
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'] as String? ?? '',
      eventId: json['event_id'] as String? ?? json['eventId'] as String? ?? '',
      eventTitle: json['event_title'] as String? ?? json['eventTitle'] as String? ?? '',
      studentId: json['student_id'] as String? ?? json['studentId'] as String? ?? '',
      studentUSN: json['student_usn'] as String? ?? json['studentUSN'] as String? ?? '',
      studentName: json['student_name'] as String? ?? json['studentName'] as String? ?? '',
      studentEmail: json['student_email'] as String? ?? json['studentEmail'] as String? ?? '',
      studentPhone: json['student_phone'] as String? ?? json['studentPhone'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      semester: json['semester'] as int? ?? (json['semester'] as num?)?.toInt() ?? 1,
      registrationDate: json['registration_date'] != null
          ? DateTime.tryParse(json['registration_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: RegistrationStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (json['status'] as String? ?? '').toLowerCase(),
        orElse: () => RegistrationStatus.confirmed,
      ),
      paymentStatus: json['payment_status'] as String? ?? json['paymentStatus'] as String? ?? 'free',
      paymentReference: json['payment_reference'] as String? ?? json['paymentReference'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      customResponses: (json['custom_responses'] as Map<String, dynamic>?) ??
          (json['customResponses'] as Map<String, dynamic>?) ??
          const {},
    );
  }

  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? studentId,
    String? studentUSN,
    String? studentName,
    String? studentEmail,
    String? studentPhone,
    String? branch,
    int? semester,
    DateTime? registrationDate,
    RegistrationStatus? status,
    String? paymentStatus,
    String? paymentReference,
    double? amount,
    Map<String, dynamic>? customResponses,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      studentId: studentId ?? this.studentId,
      studentUSN: studentUSN ?? this.studentUSN,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentPhone: studentPhone ?? this.studentPhone,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentReference: paymentReference ?? this.paymentReference,
      amount: amount ?? this.amount,
      customResponses: customResponses ?? this.customResponses,
    );
  }
}
