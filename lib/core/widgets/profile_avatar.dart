import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String gender;
  final String name;
  final double radius;
  final bool isBlurred;
  final bool isVerified;
  final bool isOnline;
  final VoidCallback? onTap;
  final Border? border;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.gender = 'Female',
    this.name = '',
    this.radius = 36,
    this.isBlurred = false,
    this.isVerified = false,
    this.isOnline = false,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = gender.toLowerCase() == 'male';

    Widget imageWidget;
    final hasValidImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    if (hasValidImage) {
      final path = imageUrl!.trim();
      if (path.startsWith('http://') || path.startsWith('https://')) {
        imageWidget = Image.network(
          path,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (_, __, ___) => _buildFallback(isMale),
        );
      } else if (path.startsWith('assets/')) {
        imageWidget = Image.asset(
          path,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (_, __, ___) => _buildFallback(isMale),
        );
      } else if (File(path).existsSync()) {
        imageWidget = Image.file(
          File(path),
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (_, __, ___) => _buildFallback(isMale),
        );
      } else {
        imageWidget = _buildFallback(isMale);
      }
    } else {
      imageWidget = _buildFallback(isMale);
    }

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          imageWidget,
          if (isBlurred) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withAlpha(80),
                  child: const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: border ??
                  Border.all(
                    color: AppColors.saffronOrange.withAlpha(60),
                    width: 2,
                  ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: content,
          ),
          if (isVerified)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: AppColors.successGreen,
                  size: 18,
                ),
              ),
            )
          else if (isOnline)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback(bool isMale) {
    final gradient = isMale
        ? const LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFE2670A), Color(0xFFD6336C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : (isMale ? 'M' : 'F');

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
