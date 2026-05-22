class Project {
  final int? id;
  final String? remoteId;
  final int userId;
  final String projectName;
  final String? developer;
  final String? architect;
  final String? pmc;
  final String? facadeConsultant;
  final String segment;
  final String status;
  final String? outcome;
  final String? remarks;
  final double latitude;
  final double longitude;
  final String? photoPath;
  final int createdAt;
  final int updatedAt;

  const Project({
    this.id,
    this.remoteId,
    required this.userId,
    required this.projectName,
    required this.developer,
    required this.architect,
    required this.pmc,
    required this.facadeConsultant,
    required this.segment,
    required this.status,
    required this.outcome,
    required this.remarks,
    required this.latitude,
    required this.longitude,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'remote_id': remoteId,
        'user_id': userId,
        'project_name': projectName,
        'developer': developer,
        'architect': architect,
        'pmc': pmc,
        'facade_consultant': facadeConsultant,
        'segment': segment,
        'status': status,
        'outcome': outcome,
        'remarks': remarks,
        'latitude': latitude,
        'longitude': longitude,
        'photo_path': photoPath,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'] as int?,
        remoteId: map['remote_id'] as String?,
        userId: map['user_id'] as int,
        projectName: map['project_name'] as String,
        developer: map['developer'] as String?,
        architect: map['architect'] as String?,
        pmc: map['pmc'] as String?,
        facadeConsultant: map['facade_consultant'] as String?,
        segment: map['segment'] as String,
        status: map['status'] as String,
        outcome: map['outcome'] as String?,
        remarks: map['remarks'] as String?,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        photoPath: map['photo_path'] as String?,
        createdAt: map['created_at'] as int,
        updatedAt: map['updated_at'] as int,
      );
}

class SyncQueueItem {
  final int? id;
  final String idempotencyKey;
  final String operation;
  final String entityId;
  final String payloadJson;
  final String status;

  const SyncQueueItem({
    this.id,
    required this.idempotencyKey,
    required this.operation,
    required this.entityId,
    required this.payloadJson,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'idempotency_key': idempotencyKey,
        'operation': operation,
        'entity_id': entityId,
        'payload_json': payloadJson,
        'status': status,
      };
}
