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
  final Map<String, int>? localityCounts;
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
    this.localityCounts,
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
    Map<String, int>? localityCounts,
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
        localityCounts: localityCounts,
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
  late Set<String> _selectedLocalities;
  String _localitySearch = '';

  static const List<String> _allLocalityList = [
    'Mudaliarpet',
    'Nellithope',
    'Lawspet',
    'Muthialpet',
    'Reddiarpalayam',
    'White Town',
    'Heritage Town',
    'Ariyankuppam',
    'Villianur',
    'Ozhukarai',
    'Kalapet',
    'Auroville',
    'Bahour',
    'Embalam',
    'Kurumbapet',
    'Thattanchavady',
    'Saram',
    'Rainbow Nagar',
    'Anna Nagar',
    'Uppalam',
    'Karaikal Town',
  ];

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
    _selectedLocalities = Set<String>.from(c.localities);
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
    count += _selectedLocalities.length;
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
      _selectedLocalities.clear();
      _localitySearch = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.90;

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
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      label: const Text('Nearby (Pondy/TN)'),
                      selected: _nearbyOnly,
                      selectedColor: AppColors.saffronOrange.withAlpha(40),
                      checkmarkColor: AppColors.saffronOrange,
                      onSelected: (val) => setState(() => _nearbyOnly = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Locality Filter Section (§Feature 4)
                _buildSectionTitle('Locality / Neighbourhood (Puducherry & Karaikal)'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search locality (e.g. Mudaliarpet, Lawspet...)',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onChanged: (val) => setState(() => _localitySearch = val.toLowerCase().trim()),
                      ),
                    ),
                    if (_selectedLocalities.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => setState(() => _selectedLocalities.clear()),
                        child: const Text('Clear', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allLocalityList
                      .where((loc) => _localitySearch.isEmpty || loc.toLowerCase().contains(_localitySearch))
                      .map((loc) {
                    final isSel = _selectedLocalities.contains(loc);
                    final count = widget.localityCounts?[loc] ?? 0;
                    final countStr = count > 0 ? ' ($count)' : '';
                    return FilterChip(
                      label: Text('$loc$countStr'),
                      selected: isSel,
                      selectedColor: AppColors.saffronOrange.withAlpha(40),
                      checkmarkColor: AppColors.saffronOrange,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSel ? AppColors.saffronOrange : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedLocalities.add(loc);
                          } else {
                            _selectedLocalities.remove(loc);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Age Range
                _buildSectionTitle('Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()} yrs'),
                RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 60,
                  divisions: 42,
                  activeColor: AppColors.saffronOrange,
                  inactiveColor: Colors.grey.shade300,
                  labels: RangeLabels('${_ageRange.start.round()}', '${_ageRange.end.round()}'),
                  onChanged: (v) => setState(() => _ageRange = v),
                ),
                const SizedBox(height: 16),

                // Height Range
                _buildSectionTitle('Height Range: ${_formatCmToFtIn(_heightRange.start.round())} - ${_formatCmToFtIn(_heightRange.end.round())}'),
                RangeSlider(
                  values: _heightRange,
                  min: 130,
                  max: 210,
                  divisions: 80,
                  activeColor: AppColors.saffronOrange,
                  inactiveColor: Colors.grey.shade300,
                  labels: RangeLabels('${_heightRange.start.round()} cm', '${_heightRange.end.round()} cm'),
                  onChanged: (v) => setState(() => _heightRange = v),
                ),
                const SizedBox(height: 16),

                // Marital Status
                _buildSectionTitle('Marital Status'),
                DropdownButtonFormField<String>(
                  value: _maritalStatus,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Any Marital Status')),
                    DropdownMenuItem(value: 'never_married', child: Text('Never Married')),
                    DropdownMenuItem(value: 'widower', child: Text('Widower / Widow')),
                    DropdownMenuItem(value: 'divorced', child: Text('Divorced')),
                    DropdownMenuItem(value: 'awaiting_divorce', child: Text('Awaiting Divorce')),
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
                    DropdownMenuItem(value: 'all', child: Text('Any Religion')),
                    DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
                    DropdownMenuItem(value: 'christian', child: Text('Christian')),
                    DropdownMenuItem(value: 'muslim', child: Text('Muslim')),
                    DropdownMenuItem(value: 'jain', child: Text('Jain')),
                  ],
                  onChanged: (v) => setState(() => _religion = v ?? 'all'),
                ),
                const SizedBox(height: 16),

                // Caste / Subcaste
                _buildSectionTitle('Caste'),
                DropdownButtonFormField<String>(
                  value: _caste,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Any Caste / Willing Other Caste')),
                    DropdownMenuItem(value: 'mudaliar', child: Text('Mudaliar')),
                    DropdownMenuItem(value: 'vanniyar', child: Text('Vanniyar / Padayachi')),
                    DropdownMenuItem(value: 'pillai', child: Text('Pillai')),
                    DropdownMenuItem(value: 'brahmin', child: Text('Brahmin (Iyer / Iyengar)')),
                    DropdownMenuItem(value: 'nadar', child: Text('Nadar')),
                    DropdownMenuItem(value: 'chettiar', child: Text('Chettiar')),
                    DropdownMenuItem(value: 'thevar', child: Text('Thevar / Mukkalathor')),
                    DropdownMenuItem(value: 'yadava', child: Text('Yadava')),
                    DropdownMenuItem(value: 'meenavar', child: Text('Meenavar / Pattanavar')),
                  ],
                  onChanged: (v) => setState(() => _caste = v ?? 'all'),
                ),
                const SizedBox(height: 16),

                // District
                _buildSectionTitle('District / Region'),
                DropdownButtonFormField<String>(
                  value: _district,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Any Location')),
                    DropdownMenuItem(value: 'puducherry', child: Text('Puducherry')),
                    DropdownMenuItem(value: 'karaikal', child: Text('Karaikal')),
                    DropdownMenuItem(value: 'cuddalore', child: Text('Cuddalore')),
                    DropdownMenuItem(value: 'villupuram', child: Text('Villupuram')),
                    DropdownMenuItem(value: 'chennai', child: Text('Chennai')),
                  ],
                  onChanged: (v) => setState(() => _district = v ?? 'all'),
                ),
                const SizedBox(height: 16),

                // Horoscope
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.saffronOrange,
                  title: const Text('Horoscope available only', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Filters profiles with Raasi/Star info', style: TextStyle(fontSize: 12)),
                  value: _hasHoroscope,
                  onChanged: (v) => setState(() => _hasHoroscope = v),
                ),
                const SizedBox(height: 16),

                // Distance Radius
                _buildSectionTitle('Distance Radius'),
                Wrap(
                  spacing: 8,
                  children: [null, 10, 25, 50, 100].map((radius) {
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
                    localities: _selectedLocalities.toList(),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  String _formatCmToFtIn(int cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }
}
