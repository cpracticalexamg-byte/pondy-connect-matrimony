import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OccupationChipData {
  final String code;
  final String label;
  final IconData icon;

  const OccupationChipData({
    required this.code,
    required this.label,
    required this.icon,
  });
}

class OccupationChipsStrip extends StatelessWidget {
  final Set<String> selectedOccupations;
  final ValueChanged<String> onToggleOccupation;
  final VoidCallback onSameProfession;
  final VoidCallback onMore;

  const OccupationChipsStrip({
    super.key,
    required this.selectedOccupations,
    required this.onToggleOccupation,
    required this.onSameProfession,
    required this.onMore,
  });

  static const List<OccupationChipData> quickChips = [
    OccupationChipData(code: 'doctor', label: 'Doctor', icon: Icons.medical_services_outlined),
    OccupationChipData(code: 'techie', label: 'Techie (IT & Software)', icon: Icons.computer_outlined),
    OccupationChipData(code: 'advocate', label: 'Advocate (Legal)', icon: Icons.gavel_outlined),
    OccupationChipData(code: 'engineer', label: 'Engineer', icon: Icons.engineering_outlined),
    OccupationChipData(code: 'professor', label: 'Teacher / Professor', icon: Icons.school_outlined),
    OccupationChipData(code: 'ca', label: 'Chartered Accountant', icon: Icons.calculate_outlined),
    OccupationChipData(code: 'business', label: 'Business', icon: Icons.business_center_outlined),
    OccupationChipData(code: 'government', label: 'Government', icon: Icons.account_balance_outlined),
    OccupationChipData(code: 'defence', label: 'Defence', icon: Icons.security_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // "Same profession as me" chip
            ActionChip(
              avatar: const Icon(Icons.stars, size: 16, color: AppColors.saffronOrange),
              label: const Text(
                'Same profession as me',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.saffronOrange,
                ),
              ),
              backgroundColor: AppColors.saffronOrange.withAlpha(20),
              side: const BorderSide(color: AppColors.saffronOrange, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: onSameProfession,
            ),
            const SizedBox(width: 8),

            // Standard quick chips
            ...quickChips.map((chip) {
              final isSelected = selectedOccupations.contains(chip.code);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  avatar: Icon(
                    isSelected ? Icons.check_circle : chip.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  label: Text(chip.label),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.saffronOrange,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected ? AppColors.saffronOrange : Colors.grey.shade300,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => onToggleOccupation(chip.code),
                ),
              );
            }),

            // "More..." chip
            ActionChip(
              avatar: const Icon(Icons.tune, size: 16, color: AppColors.textSecondary),
              label: const Text(
                'More…',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: onMore,
            ),
          ],
        ),
      ),
    );
  }
}
