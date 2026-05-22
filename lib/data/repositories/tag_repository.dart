import '../local/session_store.dart';
import '../models/tag_entry.dart';
import '../models/visit_entry.dart';
import '../remote/sitepin_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagRepository {
  TagRepository({required this.api, required this.sessionStore});

  final SitePinApiClient api;
  final SessionStore sessionStore;
  static const _kLegacyCleanupDone = 'tag_repo_legacy_cleanup_v1_done';

  Future<void> _cleanupLegacyLocalTagCacheOnce() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_kLegacyCleanupDone) == true) return;
    await p.remove('saved_tag_entries');
    await p.remove('tag_count_stakeholder');
    await p.remove('tag_count_partner');
    await p.setBool(_kLegacyCleanupDone, true);
  }

  Future<List<TagEntry>> allTagEntries({
    String? tagType,
    String? category,
    int limit = 500,
    int offset = 0,
  }) async {
    await _cleanupLegacyLocalTagCacheOnce();
    final token = await sessionStore.accessToken();
    if (token == null) return [];
    final res = await api.get(
      'api/v1/tags',
      token: token,
      query: {
        'limit': '$limit',
        'offset': '$offset',
        if (tagType != null && tagType.isNotEmpty) 'tagType': tagType,
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    final rows = (res['tags'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return rows
        .map(
          (row) => TagEntry(
            id: row['id']?.toString(),
            tagType: (row['tagType'] ?? '').toString(),
            category: (row['category'] ?? '').toString(),
            entityName: (row['entityName'] ?? '').toString(),
            contactPerson: row['contactPerson']?.toString(),
            phone: row['phone']?.toString(),
            email: row['email']?.toString(),
            address: row['address']?.toString(),
            latitude: (row['latitude'] as num).toDouble(),
            longitude: (row['longitude'] as num).toDouble(),
            capturedAt: (row['capturedAt'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  Future<void> saveTagEntry(TagEntry entry) async {
    final token = await sessionStore.accessToken();
    if (token == null) return;
    await api.post(
      'api/v1/tags',
      {
        'tagType': entry.tagType,
        'category': entry.category,
        'entityName': entry.entityName,
        'contactPerson': entry.contactPerson,
        'phone': entry.phone,
        'email': entry.email,
        'address': entry.address,
        'latitude': entry.latitude,
        'longitude': entry.longitude,
        'capturedAt': entry.capturedAt,
      },
      token: token,
    );
  }

  Future<void> updateTagEntry(TagEntry entry) async {
    if (entry.id == null || entry.id!.isEmpty) return;
    final token = await sessionStore.accessToken();
    if (token == null) return;
    await api.put(
      'api/v1/tags/${entry.id}',
      {
        'tagType': entry.tagType,
        'category': entry.category,
        'entityName': entry.entityName,
        'contactPerson': entry.contactPerson,
        'phone': entry.phone,
        'email': entry.email,
        'address': entry.address,
        'latitude': entry.latitude,
        'longitude': entry.longitude,
        'capturedAt': entry.capturedAt,
      },
      token: token,
    );
  }

  Future<int> stakeholderCount() async {
    final entries = await allTagEntries();
    return entries.where((e) => e.tagType == 'Stakeholder').length;
  }

  Future<int> partnerCount() async {
    final entries = await allTagEntries();
    return entries.where((e) => e.tagType == 'Partner').length;
  }

  Future<List<VisitEntry>> listVisits({
    required String tagId,
    int limit = 200,
    int offset = 0,
  }) async {
    final token = await sessionStore.accessToken();
    if (token == null) return [];
    final res = await api.get(
      'api/v1/visits',
      token: token,
      query: {
        'tagId': tagId,
        'limit': '$limit',
        'offset': '$offset',
      },
    );
    final rows = (res['visits'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return rows
        .map(
          (row) => VisitEntry(
            id: row['id']?.toString(),
            tagId: (row['tagId'] ?? '').toString(),
            userId: row['userId']?.toString(),
            visitDate: (row['visitDate'] as num?)?.toInt() ?? 0,
            discussionPoints: (row['discussionPoints'] ?? '').toString(),
            nextAction: row['nextAction']?.toString(),
            createdAt: (row['createdAt'] as num?)?.toInt(),
            updatedAt: (row['updatedAt'] as num?)?.toInt(),
          ),
        )
        .toList();
  }

  Future<void> createVisit({
    required String tagId,
    required int visitDate,
    required String discussionPoints,
    String? nextAction,
  }) async {
    final token = await sessionStore.accessToken();
    if (token == null) return;
    await api.post(
      'api/v1/visits',
      {
        'tagId': tagId,
        'visitDate': visitDate,
        'discussionPoints': discussionPoints,
        'nextAction': nextAction,
      },
      token: token,
    );
  }
}
