class WorkspaceModel {
  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.businessName,
    this.businessCategory,
    required this.slug,
    this.timezone = 'UTC',
    this.country = 'United States',
    required this.ownerId,
    this.userRole = 'OWNER',
    this.createdAt,
  });

  final String id;
  final String name;
  final String businessName;
  final String? businessCategory;
  final String slug;
  final String timezone;
  final String country;
  final String ownerId;
  final String userRole;
  final DateTime? createdAt;

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'My Workspace',
      businessName: json['businessName']?.toString() ?? 'Business',
      businessCategory: json['businessCategory']?.toString(),
      slug: json['slug']?.toString() ?? 'workspace',
      timezone: json['timezone']?.toString() ?? 'UTC',
      country: json['country']?.toString() ?? 'United States',
      ownerId: json['ownerId']?.toString() ?? '',
      userRole: json['userRole']?.toString() ?? 'OWNER',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'businessName': businessName,
    'businessCategory': businessCategory,
    'slug': slug,
    'timezone': timezone,
    'country': country,
    'ownerId': ownerId,
    'userRole': userRole,
    'createdAt': createdAt?.toIso8601String(),
  };

  WorkspaceModel copyWith({
    String? id,
    String? name,
    String? businessName,
    String? businessCategory,
    String? slug,
    String? timezone,
    String? country,
    String? ownerId,
    String? userRole,
    DateTime? createdAt,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      slug: slug ?? this.slug,
      timezone: timezone ?? this.timezone,
      country: country ?? this.country,
      ownerId: ownerId ?? this.ownerId,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

