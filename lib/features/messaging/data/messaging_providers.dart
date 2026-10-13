import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../domain/message_models.dart';
import 'messaging_repository.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => MessagingRepository(ref.watch(apiClientProvider)),
);

/// Conversation contacts (people the user already completed a visit with).
final contactsProvider = FutureProvider.autoDispose<List<ChatContact>>(
  (ref) => ref.watch(messagingRepositoryProvider).contacts(),
);

/// Arguments identifying the other side of a conversation.
class ConversationArgs {
  const ConversationArgs(this.otherId, this.otherType);
  final int otherId;
  final String otherType; // 'doctor' | 'patient'

  @override
  bool operator ==(Object other) =>
      other is ConversationArgs &&
      other.otherId == otherId &&
      other.otherType == otherType;

  @override
  int get hashCode => Object.hash(otherId, otherType);
}

/// Messages of a single conversation, keyed by the other participant.
final conversationProvider = FutureProvider.autoDispose
    .family<List<ChatMessage>, ConversationArgs>(
      (ref, args) => ref
          .watch(messagingRepositoryProvider)
          .messages(otherId: args.otherId, otherType: args.otherType),
    );

/// Loads an authenticated chat attachment (bytes) by its server path.
final attachmentProvider = FutureProvider.autoDispose.family<Uint8List?, String>(
  (ref, path) => ref.watch(messagingRepositoryProvider).attachment(path),
);
