import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SortOptionItem {
  final String code;
  final String title;
  final String description;

  const SortOptionItem({
    required this.code,
    required this.title,
    required this.description,
  });
}

class SortSheet extends StatefulWidget {
  final String currentSort;
  final ValueChanged<String> onApply;
  final VoidCallback? onReset;

  const SortSheet({
    super.key,
    required this.currentSort,
    required this.onApply,
    this.onReset,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentSort,
    required ValueChanged<String> onApply,
    VoidCallback? onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SortSheet(
        currentSort: currentSort,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<SortSheet> {
  late String _selectedSort;

  static const List<SortOptionItem> _options = [
    SortOptionItem(
      code: 'last_active',
      title: 'Last active',
      description: 'Members who recently logged in shown first (default)',
    ),
    SortOptionItem(
      code: 'date_created',
      title: 'Date created',
      description: 'Recently created profiles first',
    ),
    SortOptionItem(
      code: 'distance',
      title: 'Distance',
      description: 'Nearby profiles first (enable location if needed)',
    ),
    SortOptionItem(
      code: 'latest_photos',
      title: 'Latest photos',
      description: 'Members who recently added photos first',
    ),
    SortOptionItem(
      code: 'best_match',
      title: 'Best match %',
      description: 'Profiles with highest compatibility percentage first',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort matches by:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSort = 'last_active';
                    });
                    if (widget.onReset != null) widget.onReset!();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.saffronOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Radio options list
            ..._options.map((opt) {
              final isSelected = _selectedSort == opt.code;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedSort = opt.code;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: opt.code,
                        groupValue: _selectedSort,
                        activeColor: AppColors.saffronOrange,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSort = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.saffronOrange : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              opt.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffronOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  widget.onApply(_selectedSort);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Apply Sort',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
