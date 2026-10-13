/// Domain models for the messaging feature (المرحلة 2 — الرسائل).
///
/// Mirrors the web backend contracts:
///   • GET /api/messages/contacts  → {contacts:[...]}
///   • GET /api/messages?otherId=&otherType=doctor|patient → {messages:[...]}
///   • POST /api/messages {receiverId, receiverType, content, imageUrl?}
///
/// A conversation is only permitted AFTER a visit with status done/completed,
/// so the contacts list only ever returns people the user already visited.
library;

class ChatContact {
  const ChatContact({
    required this.id,
    required this.name,
    this.phone = '',
    this.specialty,
    this.address,
    this.fee,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String phone;

  // Present only when the contact is a doctor (i.e. the current user is a patient).
  final String? specialty;
  final String? address;
  final num? fee;
  final String? photoUrl;

  factory ChatContact.fromJson(Map<String, dynamic> j) => ChatContact(
    id: _i(j['id']) ?? 0,
    name: j['name']?.toString() ?? '',
    phone: j['phone']?.toString() ?? '',
    specialty: j['specialty']?.toString(),
    address: j['address']?.toString(),
    fee: j['fee'] is num ? j['fee'] as num : num.tryParse('${j['fee']}'),
    photoUrl: j['photoUrl']?.toString(),
  );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    this.imageUrl,
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final int senderId;
  final String senderType;
  final int receiverId;
  final String receiverType;
  final String content;

  /// Server returns an authenticated relative path like
  /// `/api/messages/attachments/{id}` — never a public URL. Must be fetched
  /// through the authenticated dio client (session cookie), not Image.network.
  final String? imageUrl;
  final bool isRead;
  final DateTime? createdAt;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// True when the message was sent by [userId]/[userType] (the current user).
  bool mine(int userId, String userType) =>
      senderId == userId && senderType == userType;

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: _i(j['id']) ?? 0,
    senderId: _i(j['senderId']) ?? 0,
    senderType: j['senderType']?.toString() ?? '',
    receiverId: _i(j['receiverId']) ?? 0,
    receiverType: j['receiverType']?.toString() ?? '',
    content: j['content']?.toString() ?? '',
    imageUrl: (j['imageUrl'] == null || '${j['imageUrl']}'.isEmpty)
        ? null
        : j['imageUrl'].toString(),
    isRead: j['isRead'] == true,
    createdAt: DateTime.tryParse('${j['createdAt']}')?.toLocal(),
  );
}

int? _i(Object? v) => v is int ? v : int.tryParse('$v');
