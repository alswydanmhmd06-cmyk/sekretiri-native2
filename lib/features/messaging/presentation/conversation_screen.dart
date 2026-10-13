import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/app_user.dart';
import '../data/messaging_providers.dart';
import '../domain/message_models.dart';
import 'auth_image.dart';

/// A single doctor ↔ patient conversation: bubbles + text/image composer.
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    required this.user,
    required this.otherId,
    required this.otherType,
    required this.title,
    this.subtitle,
    this.photoUrl,
    super.key,
  });

  final AppUser user;
  final int otherId;
  final String otherType; // 'doctor' | 'patient'
  final String title;
  final String? subtitle;
  final String? photoUrl;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _input = TextEditingController();
  final _picker = ImagePicker();
  bool _sending = false;

  ConversationArgs get _args =>
      ConversationArgs(widget.otherId, widget.otherType);

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    await _send(content: text);
  }

  Future<void> _sendImage() async {
    if (_sending) return;
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mime = _mimeFor(file.name);
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    await _send(imageDataUrl: dataUrl);
  }

  String _mimeFor(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _send({String content = '', String? imageDataUrl}) async {
    setState(() => _sending = true);
    try {
      await ref
          .read(messagingRepositoryProvider)
          .send(
            receiverId: widget.otherId,
            receiverType: widget.otherType,
            content: content,
            imageDataUrl: imageDataUrl,
          );
      _input.clear();
      ref.invalidate(conversationProvider(_args));
    } on ApiFailure catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('تعذر إرسال الرسالة. حاول مجدداً.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(conversationProvider(_args));
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
              backgroundImage:
                  (widget.photoUrl != null &&
                      widget.photoUrl!.startsWith('http'))
                  ? NetworkImage(widget.photoUrl!)
                  : null,
              child:
                  (widget.photoUrl == null ||
                      !widget.photoUrl!.startsWith('http'))
                  ? Text(
                      widget.title.isNotEmpty
                          ? widget.title.characters.first
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                    Text(
                      widget.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.when(
              data: (list) => list.isEmpty
                  ? _EmptyThread()
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(conversationProvider(_args)),
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        itemCount: list.length,
                        itemBuilder: (c, i) {
                          final m = list[list.length - 1 - i];
                          return _Bubble(
                            message: m,
                            mine: m.mine(widget.user.id, widget.user.type),
                          );
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ThreadError(
                message: e.toString(),
                onRetry: () => ref.invalidate(conversationProvider(_args)),
              ),
            ),
          ),
          _Composer(
            controller: _input,
            sending: _sending,
            onSend: _sendText,
            onAttach: _sendImage,
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});
  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final bg = mine ? AppTheme.primary : Colors.white;
    final fg = mine ? Colors.white : AppTheme.textPrimary;
    return Align(
      alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 4 : 18),
            bottomRight: Radius.circular(mine ? 18 : 4),
          ),
          boxShadow: mine ? null : AppTheme.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.hasImage) ...[
              AuthImage(path: message.imageUrl!, width: 220, height: 220),
              if (message.content.isNotEmpty) const SizedBox(height: 8),
            ],
            if (message.content.isNotEmpty)
              Text(
                message.content,
                style: TextStyle(color: fg, height: 1.5, fontSize: 14.5),
              ),
            const SizedBox(height: 4),
            Text(
              _time(message.createdAt),
              style: TextStyle(
                color: mine ? Colors.white70 : AppTheme.textMuted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _time(DateTime? d) {
    if (d == null) return '';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'ص' : 'م';
    return '$h:$m $period';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onAttach,
  });
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: sending ? null : onAttach,
              icon: const Icon(Icons.image_rounded, color: AppTheme.primary),
              tooltip: 'إرسال صورة',
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة…',
                  filled: true,
                  fillColor: AppTheme.surfaceDim,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: AppTheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: sending ? null : onSend,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(28, 80, 28, 28),
    children: const [
      Icon(Icons.chat_bubble_outline_rounded, size: 54, color: AppTheme.primary),
      SizedBox(height: 14),
      Text(
        'ابدأ المحادثة',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
      SizedBox(height: 8),
      Text(
        'أرسل أول رسالة نصية أو صورة لبدء التواصل.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textSecondary, height: 1.7),
      ),
    ],
  );
}

class _ThreadError extends StatelessWidget {
  const _ThreadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(28, 80, 28, 28),
    children: [
      const Icon(Icons.cloud_off_rounded, color: AppTheme.error, size: 34),
      const SizedBox(height: 10),
      const Text(
        'تعذر تحميل الرسائل',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      Center(
        child: TextButton(
          onPressed: onRetry,
          child: const Text('إعادة المحاولة'),
        ),
      ),
    ],
  );
}
