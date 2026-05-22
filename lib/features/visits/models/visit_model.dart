class VisitTypes {
  static const clientMeeting = 'Client Meeting';
  static const partnerVisit = 'Partner Visit';
  static const siteInspection = 'Site Inspection';
  static const internalReview = 'Internal Review';
  static const governmentVisit = 'Government Visit';

  static const all = [
    clientMeeting,
    partnerVisit,
    siteInspection,
    internalReview,
    governmentVisit,
  ];
}

class VisitOutcomeStatus {
  static const successful = 'Successful';
  static const followUpRequired = 'Follow-up Required';
  static const blocked = 'Blocked';
  static const escalated = 'Escalated';
  static const pendingClarification = 'Pending Clarification';

  static const all = [
    successful,
    followUpRequired,
    blocked,
    escalated,
    pendingClarification,
  ];
}

class VisitSyncStatus {
  static const pendingUpload = 'pending_upload';
  static const synced = 'synced';
  static const failedRetryable = 'failed_retryable';
}

class VisitModel {
  const VisitModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.visitType,
    required this.visitDate,
    this.startTime,
    this.endTime,
    this.clientName,
    this.partnerName,
    this.attendees,
    this.discussionPoints,
    this.decisionsTaken,
    this.actionItems,
    this.outcomeStatus,
    this.latitude,
    this.longitude,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final int userId;
  final String visitType;
  final int visitDate;
  final String? startTime;
  final String? endTime;
  final String? clientName;
  final String? partnerName;
  final String? attendees;
  final String? discussionPoints;
  final String? decisionsTaken;
  final String? actionItems;
  final String? outcomeStatus;
  final double? latitude;
  final double? longitude;
  final String syncStatus;
  final int createdAt;
  final int updatedAt;

  VisitModel copyWith({
    String? id,
    String? projectId,
    int? userId,
    String? visitType,
    int? visitDate,
    String? startTime,
    String? endTime,
    String? clientName,
    String? partnerName,
    String? attendees,
    String? discussionPoints,
    String? decisionsTaken,
    String? actionItems,
    String? outcomeStatus,
    double? latitude,
    double? longitude,
    String? syncStatus,
    int? createdAt,
    int? updatedAt,
  }) {
    return VisitModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      visitType: visitType ?? this.visitType,
      visitDate: visitDate ?? this.visitDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      clientName: clientName ?? this.clientName,
      partnerName: partnerName ?? this.partnerName,
      attendees: attendees ?? this.attendees,
      discussionPoints: discussionPoints ?? this.discussionPoints,
      decisionsTaken: decisionsTaken ?? this.decisionsTaken,
      actionItems: actionItems ?? this.actionItems,
      outcomeStatus: outcomeStatus ?? this.outcomeStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'user_id': userId,
        'visit_type': visitType,
        'visit_date': visitDate,
        'start_time': startTime,
        'end_time': endTime,
        'client_name': clientName,
        'partner_name': partnerName,
        'attendees': attendees,
        'discussion_points': discussionPoints,
        'decisions_taken': decisionsTaken,
        'action_items': actionItems,
        'outcome_status': outcomeStatus,
        'latitude': latitude,
        'longitude': longitude,
        'sync_status': syncStatus,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory VisitModel.fromJson(Map<String, dynamic> json) => VisitModel(
        id: (json['id'] ?? '').toString(),
        projectId: (json['project_id'] ?? json['projectId'] ?? '').toString(),
        userId: (json['user_id'] ?? json['userId'] ?? 0) as int,
        visitType: (json['visit_type'] ?? json['visitType'] ?? '').toString(),
        visitDate: (json['visit_date'] ?? json['visitDate'] ?? 0) as int,
        startTime: json['start_time']?.toString() ?? json['startTime']?.toString(),
        endTime: json['end_time']?.toString() ?? json['endTime']?.toString(),
        clientName: json['client_name']?.toString() ?? json['clientName']?.toString(),
        partnerName: json['partner_name']?.toString() ?? json['partnerName']?.toString(),
        attendees: json['attendees']?.toString(),
        discussionPoints: json['discussion_points']?.toString() ?? json['discussionPoints']?.toString(),
        decisionsTaken: json['decisions_taken']?.toString() ?? json['decisionsTaken']?.toString(),
        actionItems: json['action_items']?.toString() ?? json['actionItems']?.toString(),
        outcomeStatus: json['outcome_status']?.toString() ?? json['outcomeStatus']?.toString(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        syncStatus: (json['sync_status'] ?? json['syncStatus'] ?? VisitSyncStatus.pendingUpload).toString(),
        createdAt: (json['created_at'] ?? json['createdAt'] ?? 0) as int,
        updatedAt: (json['updated_at'] ?? json['updatedAt'] ?? 0) as int,
      );
}
