import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/ads_providers.dart';
import '../domain/doctor_ad.dart';

/// Horizontal carousel of promotional doctor cards for the welcome screen.
/// Mirrors the web «أطباء مميزون» section. Hidden entirely when there are
/// no ads (the endpoint fails soft to an empty list).
class AdsCarousel extends ConsumerWidget {
  const AdsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adsProvider);
    return ads.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'أطباء مميزون',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (list.length > 1)
                    const Text(
                      'اسحب للمزيد',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (c, i) => _AdCard(ad: list[i]),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _AdCard extends StatelessWidget {
  const _AdCard({required this.ad});
  final DoctorAd ad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowElevated,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'د. ${ad.doctorName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (ad.specialty != null && ad.specialty!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    ad.specialty!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE0F2FE),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (ad.rating != null && ad.rating!.isNotEmpty)
                      _Chip(icon: Icons.star_rounded, label: ad.rating!),
                    if (ad.appointmentsCount != null)
                      _Chip(
                        icon: Icons.event_available_rounded,
                        label: '${ad.appointmentsCount}',
                      ),
                  ],
                ),
                const Spacer(),
                if (ad.clinicName != null && ad.clinicName!.isNotEmpty)
                  _Line(icon: Icons.apartment_rounded, text: ad.clinicName!),
                if (ad.clinicAddress != null && ad.clinicAddress!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _Line(
                    icon: Icons.location_on_rounded,
                    text: ad.clinicAddress!,
                    soft: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Portrait(photoUrl: ad.photoUrl),
        ],
      ),
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.photoUrl});
  final String? photoUrl;

  Uint8List? _decode(String url) {
    final idx = url.indexOf('base64,');
    if (idx == -1) return null;
    try {
      return base64Decode(url.substring(idx + 7));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final url = photoUrl;
    if (url == null || url.isEmpty) {
      child = _ph();
    } else if (url.startsWith('data:')) {
      final bytes = _decode(url);
      child = bytes == null
          ? _ph()
          : Image.memory(bytes, fit: BoxFit.cover, errorBuilder: (_, _, _) => _ph());
    } else if (url.startsWith('http')) {
      child = Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => _ph());
    } else {
      child = _ph();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(width: 92, height: double.infinity, child: child),
    );
  }

  Widget _ph() => Container(
    color: const Color(0x22FFFFFF),
    alignment: Alignment.center,
    child: const Icon(
      Icons.medical_services_rounded,
      color: Colors.white70,
      size: 30,
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0x26FFFFFF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFFD166), size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.soft = false});
  final IconData icon;
  final String text;
  final bool soft;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: soft ? Colors.white60 : Colors.white),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: soft ? Colors.white60 : Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
