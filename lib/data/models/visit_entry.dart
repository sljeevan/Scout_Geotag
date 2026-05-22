class VisitEntry {
  const VisitEntry({
    this.id,
    required this.tagId,
    this.userId,
    required this.visitDate,
    required this.discussionPoints,
    this.nextAction,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String tagId;
  final String? userId;
  final int visitDate;
  final String discussionPoints;
  final String? nextAction;
  final int? createdAt;
  final int? updatedAt;
}
