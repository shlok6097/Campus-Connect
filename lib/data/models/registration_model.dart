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
    this.customResponses = const {},
  });

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
      customResponses: customResponses ?? this.customResponses,
    );
  }
}
