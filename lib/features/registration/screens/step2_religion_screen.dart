import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/outlined_dropdown_field.dart';
import '../../../core/widgets/picker_sheet.dart';
import '../../../core/widgets/step_scaffold.dart';
import '../../../data/repositories/master_data_repository.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../providers/registration_provider.dart';

class Step2ReligionScreen extends ConsumerStatefulWidget {
  const Step2ReligionScreen({super.key});

  @override
  ConsumerState<Step2ReligionScreen> createState() => _Step2ReligionScreenState();
}

class _Step2ReligionScreenState extends ConsumerState<Step2ReligionScreen> {
  List<MasterItem> _religions = [];
  List<MasterItem> _divisions = [];
  List<MasterItem> _castes = [];
  List<MasterItem> _motherTongues = [];
  List<MasterItem> _stars = [];
  List<MasterItem> _rasis = [];
  List<MasterItem> _doshams = [];

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  Future<void> _loadMasters() async {
    final repo = MasterDataRepository.instance;
    final religions = await repo.getReligions();
    final tongues = await repo.getMotherTongues();
    final stars = await repo.getStars();
    final rasis = await repo.getRasis();
    final doshams = await repo.getDoshams();

    if (mounted) {
      setState(() {
        _religions = religions;
        _motherTongues = tongues;
        _stars = stars;
        _rasis = rasis;
        _doshams = doshams;
      });
      _loadDivisionsAndCastes();
    }
  }

  Future<void> _loadDivisionsAndCastes() async {
    final reg = ref.read(registrationProvider);
    final repo = MasterDataRepository.instance;
    final divisions = await repo.getDivisions(religionId: reg.religion);
    final castes = await repo.getCastes(religionId: reg.religion);

    if (mounted) {
      setState(() {
        _divisions = divisions;
        _castes = castes;
      });
    }
  }

  String _getLabel(List<MasterItem> list, String id, {String fallback = 'Select'}) {
    for (final item in list) {
      if (item.id == id) return item.nameEn;
    }
    return fallback;
  }

  void _selectReligion() async {
    final options = _religions.map((r) => PickerOption<String>(value: r.id, title: r.nameEn)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Religion',
      options: options,
      selectedValue: reg.religion,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateReligion(
        religion: chosen,
        division: 'none',
        caste: 'caste_none',
      );
      _loadDivisionsAndCastes();
    }
  }

  void _selectDivision() async {
    final options = _divisions.map((d) => PickerOption<String>(value: d.id, title: d.nameEn)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Division / Denomination',
      options: options,
      showSearch: true,
      selectedValue: reg.division,
      showDoNotWishToSpecify: true,
      doNotWishToSpecifyValue: 'none',
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateReligion(division: chosen);
    }
  }

  void _selectCaste() async {
    final options = _castes.map((c) => PickerOption<String>(value: c.id, title: c.nameEn)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Caste / Community',
      options: options,
      showSearch: true,
      selectedValue: reg.caste,
      showDoNotWishToSpecify: true,
      doNotWishToSpecifyValue: 'caste_none',
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateReligion(caste: chosen);
    }
  }

  void _selectMotherTongue() async {
    final options = _motherTongues.map((m) => PickerOption<String>(value: m.id, title: m.nameEn)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Mother Tongue',
      options: options,
      selectedValue: reg.motherTongue,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateReligion(motherTongue: chosen);
    }
  }

  void _selectStar() async {
    final options = _stars.map((s) => PickerOption<String>(value: s.id, title: s.nameEn)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Star / Nakshatra',
      options: options,
      showSearch: true,
      selectedValue: reg.star,
      showDoNotWishToSpecify: true,
      doNotWishToSpecifyValue: '',
      doNotWishToSpecifyLabel: "Don't know / Don't wish to specify",
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateReligion(star: chosen);
    }
  }

  void _selectRasi() async {
    final options = _rasis.map((r) => PickerOption<String>(value: r.id, title: r.nameEn)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Rasi / Zodiac',
      options: options,
      selectedValue: reg.rasi,
      showDoNotWishToSpecify: true,
      doNotWishToSpecifyValue: '',
      doNotWishToSpecifyLabel: "Don't know / Don't wish to specify",
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateReligion(rasi: chosen);
    }
  }

  void _selectDosham() async {
    final options = _doshams.map((d) => PickerOption<String>(value: d.id, title: d.nameEn)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Dosham',
      options: options,
      selectedValue: reg.dosham,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateReligion(dosham: chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final reg = ref.watch(registrationProvider);
    final prefix = auth.relationPrefix;

    final isHindu = reg.religion == 'hindu';
    final hasReligion = reg.religion.isNotEmpty;

    return StepScaffold(
      title: 'Religion Details (2/5)',
      progress: 0.40,
      isNextEnabled: hasReligion,
      onNext: () {
        context.push('/register/step3');
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${prefix}Religious & Community Details',
            style: AppTypography.titleLarge(),
          ),
          const SizedBox(height: 6),
          Text(
            'Find matches with matching faith, traditions and astrology',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Religion (always shown)
          OutlinedDropdownField(
            label: '${prefix}Religion',
            valueText: _getLabel(_religions, reg.religion),
            onTap: _selectReligion,
            isRequired: true,
          ),

          // Division / Denomination (progressively animated)
          if (hasReligion) ...[
            const SizedBox(height: 18),
            OutlinedDropdownField(
              label: '${prefix}Division / Denomination',
              valueText: _getLabel(_divisions, reg.division, fallback: 'None / Don\'t wish to specify'),
              onTap: _selectDivision,
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.15, end: 0),
          ],

          // Caste / Community (optional, non-mandatory)
          if (hasReligion) ...[
            const SizedBox(height: 18),
            OutlinedDropdownField(
              label: '${prefix}Caste (Optional)',
              valueText: _getLabel(_castes, reg.caste, fallback: 'Don\'t wish to specify'),
              onTap: _selectCaste,
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.15, end: 0),

            const SizedBox(height: 12),

            // Willing to marry from other caste checkbox
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                title: const Text(
                  'Willing to marry from other caste / sub-caste',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                value: reg.willingOtherCaste,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  ref.read(registrationProvider.notifier).updateReligion(willingOtherCaste: val ?? true);
                },
              ),
            ).animate().fadeIn(duration: 250.ms),
          ],

          // Mother tongue
          const SizedBox(height: 18),
          OutlinedDropdownField(
            label: '${prefix}Mother Tongue',
            valueText: _getLabel(_motherTongues, reg.motherTongue, fallback: 'Tamil'),
            onTap: _selectMotherTongue,
            isRequired: true,
          ),

          // Hindu Astrology fields
          if (isHindu) ...[
            const SizedBox(height: 28),
            Text(
              'Horoscope Details (Optional)',
              style: AppTypography.sectionTitle(),
            ),
            const SizedBox(height: 4),
            Text(
              'Helps calculate authentic 10-Porutham compatibility',
              style: AppTypography.caption(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            OutlinedDropdownField(
              label: 'Star / Nakshatra',
              valueText: _getLabel(_stars, reg.star, fallback: 'Select Star / Don\'t Know'),
              onTap: _selectStar,
            ),
            const SizedBox(height: 16),

            OutlinedDropdownField(
              label: 'Rasi / Moon Sign',
              valueText: _getLabel(_rasis, reg.rasi, fallback: 'Select Rasi / Don\'t Know'),
              onTap: _selectRasi,
            ),
            const SizedBox(height: 16),

            OutlinedDropdownField(
              label: 'Dosham',
              valueText: _getLabel(_doshams, reg.dosham, fallback: 'No Dosham / Don\'t Know'),
              onTap: _selectDosham,
            ),
            const SizedBox(height: 16),

            // Gothram
            TextField(
              controller: TextEditingController(text: reg.gothram),
              decoration: const InputDecoration(
                labelText: 'Gothram (Optional)',
                hintText: 'e.g. Shiva, Vishnu, etc.',
              ),
              onChanged: (val) {
                ref.read(registrationProvider.notifier).updateReligion(gothram: val.trim());
              },
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
