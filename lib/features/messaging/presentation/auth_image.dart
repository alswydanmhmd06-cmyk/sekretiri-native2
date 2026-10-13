import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/messaging_providers.dart';

/// Displays a chat image served by the authenticated attachments endpoint.
/// Image.network cannot be used here because the session cookie would not be
/// attached; instead we fetch the bytes through the dio client and render them.
class AuthImage extends ConsumerWidget {
  const AuthImage({
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(attachmentProvider(path));
    return bytes.when(
      data: (data) {
        if (data == null || data.isEmpty) return _placeholder(broken: true);
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            data,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _placeholder(broken: true),
          ),
        );
      },
      loading: () => _placeholder(),
      error: (_, _) => _placeholder(broken: true),
    );
  }

  Widget _placeholder({bool broken = false}) => Container(
    width: width ?? 180,
    height: height ?? 180,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppTheme.surfaceDim,
      borderRadius: BorderRadius.circular(14),
    ),
    child: broken
        ? const Icon(Icons.broken_image_rounded, color: AppTheme.textMuted)
        : const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
  );
}
