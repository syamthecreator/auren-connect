class WhatsAppChannelModel {
  const WhatsAppChannelModel({
    required this.id,
    required this.userId,
    this.phoneNumber,
    this.jid,
    this.name,
    this.profilePic,
    this.status = 'CONNECTING',
    this.connectedAt,
    this.createdAt,
    this.isSocketActive = false,
  });

  final String id;
  final String userId;
  final String? phoneNumber;
  final String? jid;
  final String? name;
  final String? profilePic;
  final String status;
  final DateTime? connectedAt;
  final DateTime? createdAt;
  final bool isSocketActive;

  bool get isConnected => status == 'CONNECTED';

  String get displayPhoneNumber {
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      final clean = phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length == 12 && clean.startsWith('91')) {
        // Indian number format: +91 98765 43210
        return '+91 ${clean.substring(2, 7)} ${clean.substring(7)}';
      }
      return '+$clean';
    }
    return 'Unknown Number';
  }

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!;
    }
    return displayPhoneNumber;
  }

  factory WhatsAppChannelModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppChannelModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      jid: json['jid'] as String?,
      name: json['name'] as String?,
      profilePic: json['profilePic'] as String?,
      status: json['status'] as String? ?? 'CONNECTING',
      connectedAt: json['connectedAt'] != null
          ? DateTime.tryParse(json['connectedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isSocketActive: json['isSocketActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'jid': jid,
      'name': name,
      'profilePic': profilePic,
      'status': status,
      'connectedAt': connectedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'isSocketActive': isSocketActive,
    };
  }
}
