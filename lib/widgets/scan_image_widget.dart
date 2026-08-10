import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a scan thumbnail from local path or Firebase Storage URL.
class ScanImageWidget extends StatelessWidget {
  const ScanImageWidget({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.imageBase64,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.fallbackAsset = 'assets/images/banana_landing.jpg',
  });

  final String? imagePath;
  final String? imageUrl;
  final String? imageBase64;
  final double width;
  final double height;
  final double borderRadius;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync()) {
      image = Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    } else if (imageBase64 != null && imageBase64!.trim().isNotEmpty) {
      image = _memoryImageFromBase64(imageBase64!.trim()) ?? _fallback();
    } else {
      image = _fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }

  Widget _fallback() {
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget? _memoryImageFromBase64(String value) {
    try {
      final normalized = value.contains(',') ? value.split(',').last : value;
      final Uint8List bytes = base64Decode(normalized);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } catch (e) {
      debugPrint('PLANTIVA invalid scan image_base64 skipped: $e');
      return null;
    }
  }
}

({Color chipColor, Color chipTextColor}) chipsForScanLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('healthy')) {
    return (
      chipColor: const Color(0xFFE8F5E9),
      chipTextColor: const Color(0xFF2E7D32),
    );
  }
  if (l.contains('yellow sigatoka') || l.contains('sigatoka')) {
    return (
      chipColor: const Color(0xFFFFF9C4),
      chipTextColor: const Color(0xFFF57F17),
    );
  }
  if (l.contains('panama')) {
    return (
      chipColor: const Color(0xFFFFF3E0),
      chipTextColor: const Color(0xFFEF6C00),
    );
  }
  if (l.contains('moko')) {
    return (
      chipColor: const Color(0xFFFFEBEE),
      chipTextColor: const Color(0xFFC62828),
    );
  }
  if (l.contains('mosaic') || l.contains('virus')) {
    return (
      chipColor: const Color(0xFFF3E5F5),
      chipTextColor: const Color(0xFF6A1B9A),
    );
  }
  if (l.contains('insect')) {
    return (
      chipColor: const Color(0xFFE0F7FA),
      chipTextColor: const Color(0xFF00695C),
    );
  }
  return (
    chipColor: const Color(0xFFFFEBEE),
    chipTextColor: const Color(0xFFC62828),
  );
}

String shortDiseaseName(String label) {
  final l = label.toLowerCase();
  if (l.contains('healthy')) return 'Healthy';
  if (l.contains('black sigatoka')) return 'Black Sigatoka';
  if (l.contains('yellow sigatoka')) return 'Yellow Sigatoka';
  if (l.contains('panama')) return 'Panama Disease';
  if (l.contains('moko')) return 'Moko Disease';
  if (l.contains('bract mosaic')) return 'Bract Mosaic';
  if (l.contains('insect')) return 'Insect Pest';
  return label.length > 22 ? '${label.substring(0, 20)}…' : label;
}
