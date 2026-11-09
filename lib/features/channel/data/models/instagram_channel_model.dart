class InstagramChannelModel {
  const InstagramChannelModel({
    required this.id,
    required this.instagramUserId,
    this.username,
    this.connectedAt,
    this.tokenExpiresAt,
    this.scopes = const [],
    this.isActive = true,
  });

  final String id;
  final String instagramUserId;
  final String? username;
  final DateTime? connectedAt;
  final DateTime? tokenExpiresAt;
  final List<String> scopes;
  final bool isActive;

  String get displayHandle {
    if (username != null && username!.isNotEmpty) {
      return username!.startsWith('@') ? username! : '@$username';
    }
    return '@user_$instagramUserId';
  }

  factory InstagramChannelModel.fromJson(Map<String, dynamic> json) {
    return InstagramChannelModel(
      id: json['id'] as String? ?? '',
      instagramUserId: json['instagramUserId'] as String? ?? '',
      username: json['username'] as String?,
      connectedAt: json['connectedAt'] != null
          ? DateTime.tryParse(json['connectedAt'].toString())
          : null,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.tryParse(json['tokenExpiresAt'].toString())
          : null,
      scopes: (json['scopes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instagramUserId': instagramUserId,
      'username': username,
      'connectedAt': connectedAt?.toIso8601String(),
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
      'scopes': scopes,
      'isActive': isActive,
    };
  }
}

