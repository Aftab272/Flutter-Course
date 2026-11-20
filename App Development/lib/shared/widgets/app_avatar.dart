import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Universal Avatar Widget that reliably renders:
/// 1. Asset images (e.g. assets/avatars/rana_user_avatar.png)
/// 2. Base64 data URIs from gallery uploads (data:image/jpeg;base64,...)
/// 3. Network HTTP/HTTPS URLs
/// 4. Local file paths
/// 5. Graceful fallback to user initials
class AppAvatar extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Border? border;

  const AppAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
    this.border,
  });

  String _getInitials(String input) {
    final parts = input.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? theme.colorScheme.primary,
        border: border,
      ),
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl.trim();
    if (url.isEmpty) {
      return _buildFallback(context);
    }

    Widget imageWidget;

    // 1. Base64 Data URI from gallery selection
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64String = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(
          bytes,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(context),
        );
      } catch (_) {
        return _buildFallback(context);
      }
    }
    // 2. Asset Image
    else if (url.startsWith('assets/')) {
      imageWidget = Image.asset(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(context),
      );
    }
    // 3. Network URL
    else if (url.startsWith('http://') || url.startsWith('https://')) {
      imageWidget = Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(context),
      );
    }
    // 4. Local File (Non-web)
    else if (!kIsWeb && (url.startsWith('/') || url.contains(':\\') || url.startsWith('file://'))) {
      try {
        final cleanPath = url.replaceFirst('file://', '');
        imageWidget = Image.file(
          File(cleanPath),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(context),
        );
      } catch (_) {
        return _buildFallback(context);
      }
    } else {
      return _buildFallback(context);
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: ClipOval(child: imageWidget),
    );
  }
}

