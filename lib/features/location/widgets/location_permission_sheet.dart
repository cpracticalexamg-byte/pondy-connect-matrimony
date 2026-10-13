import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';

class LocationPermissionSheet extends StatelessWidget {
  final VoidCallback onManualSelected;
  final VoidCallback? onGranted;

  const LocationPermissionSheet({
    super.key,
    required this.onManualSelected,
    this.onGranted,
  });

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onManualSelected,
    VoidCallback? onGranted,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LocationPermissionSheet(
        onManualSelected: onManualSelected,
        onGranted: onGranted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon with soft green background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_outlined, size: 40, color: Colors.teal),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Show Matches Near You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Friendly Explainer (§4 Privacy first)
            Text(
              'Enable location to discover matches nearby in Puducherry and surrounding areas.\n\n'
              '🔒 100% Privacy Protected:\n'
              'Your exact address or GPS coordinates are NEVER stored or shown to anyone. '
              'Only approximate distance (e.g. "3.4 km away") is displayed.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Primary CTA: Enable Location
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffronOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.my_location),
                label: const Text(
                  'Allow Location Access',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final status = await Permission.locationWhenInUse.request();
                  if (context.mounted) {
                    if (status.isGranted) {
                      Navigator.of(context).pop(true);
                      onGranted?.call();
                    } else {
                      // Fallback to manual district picker
                      Navigator.of(context).pop(false);
                      onManualSelected();
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 10),

            // Secondary: Set City / District Manually
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                onManualSelected();
              },
              child: const Text(
                'Set City / District Manually',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.saffronOrange,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
