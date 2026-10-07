import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PickerOption<T> {
  final T value;
  final String title;
  final String? subtitle;

  const PickerOption({
    required this.value,
    required this.title,
    this.subtitle,
  });
}

class PickerSheet<T> extends StatefulWidget {
  final String title;
  final List<PickerOption<T>> options;
  final T? selectedValue;
  final bool showSearch;
  final String searchHint;
  final bool showDoNotWishToSpecify;
  final T? doNotWishToSpecifyValue;
  final String doNotWishToSpecifyLabel;

  const PickerSheet({
    super.key,
    required this.title,
    required this.options,
    this.selectedValue,
    this.showSearch = false,
    this.searchHint = 'Search...',
    this.showDoNotWishToSpecify = false,
    this.doNotWishToSpecifyValue,
    this.doNotWishToSpecifyLabel = "Don't wish to specify",
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<PickerOption<T>> options,
    T? selectedValue,
    bool showSearch = false,
    String searchHint = 'Search...',
    bool showDoNotWishToSpecify = false,
    T? doNotWishToSpecifyValue,
    String doNotWishToSpecifyLabel = "Don't wish to specify",
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PickerSheet<T>(
        title: title,
        options: options,
        selectedValue: selectedValue,
        showSearch: showSearch,
        searchHint: searchHint,
        showDoNotWishToSpecify: showDoNotWishToSpecify,
        doNotWishToSpecifyValue: doNotWishToSpecifyValue,
        doNotWishToSpecifyLabel: doNotWishToSpecifyLabel,
      ),
    );
  }

  @override
  State<PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<PickerSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scrollToSelected() {
    if (widget.selectedValue == null || !_scrollController.hasClients) return;
    final index = widget.options.indexWhere((opt) => opt.value == widget.selectedValue);
    if (index > 4) {
      final targetOffset = (index - 2) * 56.0;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _filterQuery = query.trim().toLowerCase();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options.where((option) {
      if (_filterQuery.isEmpty) return true;
      final matchTitle = option.title.toLowerCase().contains(_filterQuery);
      final matchSub = option.subtitle?.toLowerCase().contains(_filterQuery) ?? false;
      return matchTitle || matchSub;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top grab handle & header
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.sectionTitle(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _filterQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: AppColors.scaffoldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                controller: _scrollController,
                shrinkWrap: true,
                children: [
                  if (widget.showDoNotWishToSpecify && _filterQuery.isEmpty) ...[
                    _buildOptionTile(
                      title: widget.doNotWishToSpecifyLabel,
                      isSelected: widget.selectedValue == widget.doNotWishToSpecifyValue,
                      onTap: () {
                        Navigator.of(context).pop(widget.doNotWishToSpecifyValue);
                      },
                      isHighlighted: true,
                    ),
                    const Divider(height: 1),
                  ],
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No options found',
                          style: AppTypography.bodyMedium(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...filtered.map((opt) {
                      final isSelected = opt.value == widget.selectedValue;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOptionTile(
                            title: opt.title,
                            subtitle: opt.subtitle,
                            isSelected: isSelected,
                            onTap: () {
                              Navigator.of(context).pop(opt.value);
                            },
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isSelected ? AppColors.primaryLight.withOpacity(0.5) : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isHighlighted ? AppColors.textMuted : AppColors.textPrimary),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
