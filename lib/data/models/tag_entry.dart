class TagEntry {
  const TagEntry({
    this.id,
    required this.tagType,
    required this.category,
    required this.entityName,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
  });

  final String? id;
  final String tagType;
  final String category;
  final String entityName;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final double latitude;
  final double longitude;
  final int capturedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'tag_type': tagType,
        'category': category,
        'entity_name': entityName,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'captured_at': capturedAt,
      };

  factory TagEntry.fromMap(Map<String, dynamic> map) => TagEntry(
        id: map['id'] as String?,
        tagType: map['tag_type'] as String,
        category: map['category'] as String,
        entityName: map['entity_name'] as String,
        contactPerson: map['contact_person'] as String?,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        address: map['address'] as String?,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        capturedAt: (map['captured_at'] as num).toInt(),
      );
}
