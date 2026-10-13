import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/matches_provider.dart';

class FilterSheet extends StatefulWidget {
  final MatchesFilterCriteria initialCriteria;
  final Set<String> initialOccupations;
  final bool initialPhotoOnly;
  final bool initialVerifiedOnly;
  final bool initialNotSeenOnly;
  final bool initialNearbyOnly;
  final void Function({
    required MatchesFilterCriteria criteria,
    required Set<String> occupations,
    required bool photoOnly,
    required bool verifiedOnly,
    required bool notSeenOnly,
    required bool nearbyOnly,
  }) onApply;

  const FilterSheet({
    super.key,
    required this.initialCriteria,
    required this.initialOccupations,
    required this.initialPhotoOnly,
    required this.initialVerifiedOnly,
    required this.initialNotSeenOnly,
    required this.initialNearbyOnly,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required MatchesFilterCriteria initialCriteria,
    required Set<String> initialOccupations,
    required bool initialPhotoOnly,
    required bool initialVerifiedOnly,
    required bool initialNotSeenOnly,
    required bool initialNearbyOnly,
    required void Function({
      required MatchesFilterCriteria criteria,
      required Set<String> occupations,
      required bool photoOnly,
      required bool verifiedOnly,
      required bool notSeenOnly,
      required bool nearbyOnly,
    }) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterSheet(
        initialCriteria: initialCriteria,
        initialOccupations: initialOccupations,
        initialPhotoOnly: initialPhotoOnly,
        initialVerifiedOnly: initialVerifiedOnly,
        initialNotSeenOnly: initialNotSeenOnly,
        initialNearbyOnly: initialNearbyOnly,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  // Filter variables
  late RangeValues _ageRange;
  late RangeValues _heightRange;
  late String _maritalStatus;
  late String _religion;
  late String _caste;
  late String _district;
  late String _diet;
  late int? _distanceRadius;
  late bool _hasHoroscope;
  late Set<String> _occupations;
  late bool _photoOnly;
  late bool _verifiedOnly;
  late bool _notSeenOnly;
  late bool _nearbyOnly;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCriteria;
    _ageRange = RangeValues(
      (c.ageMin ?? 20).toDouble().clamp(18, 60),
      (c.ageMax ?? 40).toDouble().clamp(18, 60),
    );
    _heightRange = RangeValues(
      (c.heightMinCm ?? 145).toDouble().clamp(130, 210),
      (c.heightMaxCm ?? 190).toDouble().clamp(130, 210),
    );
    _maritalStatus = c.maritalStatus ?? 'all';
    _religion = c.religion ?? 'all';
    _caste = c.caste ?? 'all';
    _district = c.district ?? 'all';
    _diet = c.diet ?? 'all';
    _distanceRadius = c.distanceRadiusKm;
    _hasHoroscope = c.hasHoroscope ?? false;

    _occupations = Set<String>.from(widget.initialOccupations);
    _photoOnly = widget.initialPhotoOnly;
    _verifiedOnly = widget.initialVerifiedOnly;
    _notSeenOnly = widget.initialNotSeenOnly;
    _nearbyOnly = widget.initialNearbyOnly;
  }

  int get _activeCount {
    int count = 0;
    if (_ageRange.start > 20 || _ageRange.end < 40) count++;
    if (_heightRange.start > 145 || _heightRange.end < 190) count++;
    if (_maritalStatus != 'all') count++;
    if (_religion != 'all') count++;
    if (_caste != 'all') count++;
    if (_district != 'all') count++;
    if (_diet != 'all') count++;
    if (_distanceRadius != null) count++;
    if (_hasHoroscope) count++;
    if (_occupations.isNotEmpty) count += _occupations.length;
    if (_photoOnly) count++;
    if (_verifiedOnly) count++;
    if (_notSeenOnly) count++;
    if (_nearbyOnly) count++;
    return count;
  }

  void _resetAll() {
    setState(() {
      _ageRange = const RangeValues(20, 40);
      _heightRange = const RangeValues(145, 190);
      _maritalStatus = 'all';
      _religion = 'all';
      _caste = 'all';
      _district = 'all';
      _diet = 'all';
      _distanceRadius = null;
      _hasHoroscope = false;
      _occupations.clear();
      _photoOnly = false;
      _verifiedOnly = false;
      _notSeenOnly = false;
      _nearbyOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.88;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                if (_activeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.saffronOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_activeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: _resetAll,
                  child: const Text('Reset', style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Filter Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Quick Occupation Filter Chips
                _buildSectionTitle('Quick Occupation Filter'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildOccChip('Doctor', 'doctor'),
                    _buildOccChip('Techie (IT)', 'techie'),
                    _buildOccChip('Advocate (Legal)', 'advocate'),
                    _buildOccChip('Engineer', 'engineer'),
                    _buildOccChip('Teacher/Prof', 'professor'),
                    _buildOccChip('CA/Finance', 'ca'),
                    _buildOccChip('Business', 'business'),
                    _buildOccChip('Government', 'government'),
                    _buildOccChip('Defence', 'defence'),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Toggle Badges
                _buildSectionTitle('Profile Requirements'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('With Photo'),
                      selected: _photoOnly,
                      selectedColor: AppColors.saffronOrange.withAlpha(40),
                      checkmarkColor: AppColors.saffronOrange,
                      onSelected: (val) => setState(() => _photoOnly = val),
                    ),
                    FilterChip(
                      label: const Text('Verified ID Only'),
                      selected: _verifiedOnly,
                      selectedColor: AppColors.saffronOrange.withAlpha(40),
                      checkmarkColor: AppColors.saffronOrange,
                      onSelected: (val) => setState(() => _verifiedOnly = val),
                    ),
                    FilterChip(
                      label: const Text('Not Seen Yet'),
                      selected: _notSeenOnly,
                      selectedColor: AppColors.saffronOrange.withAlpha(40),
                      checkmarkColor: AppColors.saffronOrange,
                      onSelected: (val) => setState(() => _notSeenOnly = val),
                    ),
                    FilterChip(
                      label: const Text('Nearby Only'),
                      selected: _nearbyOnly,
                      selectedColor: AppColors.saffronOrange.withAlpha(40),
                      checkmarkColor: AppColors.saffronOrange,
                      onSelected: (val) => setState(() => _nearbyOnly = val),
                    ),
                    FilterChip(
                      label: const Text('Has Horoscope'),
                      selected: _hasHoroscope,
                      selectedColor: AppColors.saffronOrange.withAlpha(40),
                      checkmarkColor: AppColors.saffronOrange,
                      onSelected: (val) => setState(() => _hasHoroscope = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Age Range
                _buildSectionTitle('Age: ${_ageRange.start.round()} - ${_ageRange.end.round()} yrs'),
                RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 60,
                  divisions: 42,
                  activeColor: AppColors.saffronOrange,
                  labels: RangeLabels('${_ageRange.start.round()}', '${_ageRange.end.round()}'),
                  onChanged: (vals) => setState(() => _ageRange = vals),
                ),
                const SizedBox(height: 16),

                // Height Range
                _buildSectionTitle('Height: ${_formatHeight(_heightRange.start.round())} - ${_formatHeight(_heightRange.end.round())}'),
                RangeSlider(
                  values: _heightRange,
                  min: 130,
                  max: 210,
                  divisions: 80,
                  activeColor: AppColors.saffronOrange,
                  labels: RangeLabels(_formatHeight(_heightRange.start.round()), _formatHeight(_heightRange.end.round())),
                  onChanged: (vals) => setState(() => _heightRange = vals),
                ),
                const SizedBox(height: 16),

                // Marital Status
                _buildSectionTitle('Marital Status'),
                DropdownButtonFormField<String>(
                  value: _maritalStatus,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Marital Statuses')),
                    DropdownMenuItem(value: 'never_married', child: Text('Never Married')),
                    DropdownMenuItem(value: 'divorced', child: Text('Divorced')),
                    DropdownMenuItem(value: 'widowed', child: Text('Widowed')),
                    DropdownMenuItem(value: 'separated', child: Text('Separated')),
                  ],
                  onChanged: (v) => setState(() => _maritalStatus = v ?? 'all'),
                ),
                const SizedBox(height: 16),

                // Religion
                _buildSectionTitle('Religion'),
                DropdownButtonFormField<String>(
                  value: _religion,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Religions')),
                    DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
                    DropdownMenuItem(value: 'christian', child: Text('Christian')),
                    DropdownMenuItem(value: 'muslim', child: Text('Muslim')),
                    DropdownMenuItem(value: 'jain', child: Text('Jain')),
                  ],
                  onChanged: (v) => setState(() => _religion = v ?? 'all'),
                ),
                const SizedBox(height: 16),

                // District / Location
                _buildSectionTitle('Location / District'),
                DropdownButtonFormField<String>(
                  value: _district,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Districts')),
                    DropdownMenuItem(value: 'puducherry', child: Text('Puducherry')),
                    DropdownMenuItem(value: 'karaikal', child: Text('Karaikal')),
                    DropdownMenuItem(value: 'cuddalore', child: Text('Cuddalore')),
                    DropdownMenuItem(value: 'villupuram', child: Text('Villupuram')),
                    DropdownMenuItem(value: 'chennai', child: Text('Chennai')),
                  ],
                  onChanged: (v) => setState(() => _district = v ?? 'all'),
                ),
                const SizedBox(height: 16),

                // Distance Radius
                _buildSectionTitle('Distance Radius'),
                Wrap(
                  spacing: 8,
                  children: [null, 5, 10, 25, 50, 100].map((radius) {
                    final isSel = _distanceRadius == radius;
                    return ChoiceChip(
                      label: Text(radius == null ? 'Any' : '$radius km'),
                      selected: isSel,
                      selectedColor: AppColors.saffronOrange,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _distanceRadius = radius),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Diet
                _buildSectionTitle('Diet Preference'),
                DropdownButtonFormField<String>(
                  value: _diet,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Any Diet')),
                    DropdownMenuItem(value: 'vegetarian', child: Text('Vegetarian')),
                    DropdownMenuItem(value: 'non_vegetarian', child: Text('Non-Vegetarian')),
                    DropdownMenuItem(value: 'eggetarian', child: Text('Eggetarian')),
                  ],
                  onChanged: (v) => setState(() => _diet = v ?? 'all'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffronOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  final criteria = MatchesFilterCriteria(
                    ageMin: _ageRange.start.round(),
                    ageMax: _ageRange.end.round(),
                    heightMinCm: _heightRange.start.round(),
                    heightMaxCm: _heightRange.end.round(),
                    maritalStatus: _maritalStatus == 'all' ? null : _maritalStatus,
                    religion: _religion == 'all' ? null : _religion,
                    caste: _caste == 'all' ? null : _caste,
                    district: _district == 'all' ? null : _district,
                    diet: _diet == 'all' ? null : _diet,
                    distanceRadiusKm: _distanceRadius,
                    hasHoroscope: _hasHoroscope ? true : null,
                  );

                  widget.onApply(
                    criteria: criteria,
                    occupations: _occupations,
                    photoOnly: _photoOnly,
                    verifiedOnly: _verifiedOnly,
                    notSeenOnly: _notSeenOnly,
                    nearbyOnly: _nearbyOnly,
                  );

                  Navigator.of(context).pop();
                },
                child: Text(
                  _activeCount > 0 ? 'Apply Filters ($_activeCount)' : 'Apply Filters',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildOccChip(String label, String code) {
    final isSelected = _occupations.contains(code);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.saffronOrange.withAlpha(40),
      checkmarkColor: AppColors.saffronOrange,
      onSelected: (val) {
        setState(() {
          if (val) {
            _occupations.add(code);
          } else {
            _occupations.remove(code);
          }
        });
      },
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  String _formatHeight(int cm) {
    final inches = (cm / 2.54).round();
    final ft = inches ~/ 12;
    final inch = inches % 12;
    return '$ft\'$inch" ($cm cm)';
  }
}
