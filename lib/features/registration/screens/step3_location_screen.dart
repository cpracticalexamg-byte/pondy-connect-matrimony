import 'package:flutter/material.dart';
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

class Step3LocationScreen extends ConsumerStatefulWidget {
  const Step3LocationScreen({super.key});

  @override
  ConsumerState<Step3LocationScreen> createState() => _Step3LocationScreenState();
}

class _Step3LocationScreenState extends ConsumerState<Step3LocationScreen> {
  final List<String> _countries = ['India', 'United States', 'United Arab Emirates', 'Singapore', 'Malaysia', 'United Kingdom', 'Other'];
  final List<String> _states = ['Puducherry', 'Tamil Nadu', 'Karnataka', 'Kerala', 'Andhra Pradesh', 'Telangana', 'Maharashtra', 'Other'];
  List<MasterItem> _districts = [];
  late final TextEditingController _cityController;
  late final TextEditingController _citizenshipController;

  @override
  void initState() {
    super.initState();
    final reg = ref.read(registrationProvider);
    _cityController = TextEditingController(text: reg.city);
    _citizenshipController = TextEditingController(text: reg.citizenship);
    _loadDistricts();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _citizenshipController.dispose();
    super.dispose();
  }

  Future<void> _loadDistricts() async {
    final list = await MasterDataRepository.instance.getDistricts();
    if (mounted) {
      setState(() {
        _districts = list;
      });
    }
  }

  String _getDistrictLabel(String id) {
    for (final d in _districts) {
      if (d.id == id) return d.nameEn;
    }
    return id.isNotEmpty ? id : 'Select District';
  }

  void _selectCountry() async {
    final options = _countries.map((c) => PickerOption<String>(value: c, title: c)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Residing Country',
      options: options,
      selectedValue: reg.country,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateLocation(country: chosen);
    }
  }

  void _selectState() async {
    final options = _states.map((s) => PickerOption<String>(value: s, title: s)).toList();
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select State',
      options: options,
      selectedValue: reg.state,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateLocation(
        stateName: chosen,
        district: chosen == 'Puducherry' ? 'puducherry' : 'chennai',
        city: chosen == 'Puducherry' ? 'Puducherry' : 'Chennai',
      );
    }
  }

  void _selectDistrict() async {
    final reg = ref.read(registrationProvider);
    final filtered = _districts.where((d) {
      if (reg.state == 'Puducherry') return d.extras['state'] == 'Puducherry';
      if (reg.state == 'Tamil Nadu') return d.extras['state'] == 'Tamil Nadu';
      return true;
    }).toList();

    final options = filtered.map((d) => PickerOption<String>(value: d.id, title: d.nameEn)).toList();
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select District',
      options: options,
      showSearch: true,
      selectedValue: reg.district,
    );
    if (chosen != null) {
      final name = _getDistrictLabel(chosen);
      ref.read(registrationProvider.notifier).updateLocation(
        district: chosen,
        city: name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final reg = ref.watch(registrationProvider);
    final prefix = auth.relationPrefix;

    final isStepValid = reg.country.isNotEmpty && reg.state.isNotEmpty && reg.district.isNotEmpty;

    return StepScaffold(
      title: 'Location Details (3/5)',
      progress: 0.60,
      showTeaser: true,
      matchCount: reg.realTimeMatchCount,
      isNextEnabled: isStepValid,
      onNext: () {
        context.push('/register/step4');
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${prefix}Location & Residence',
            style: AppTypography.titleLarge(),
          ),
          const SizedBox(height: 6),
          Text(
            'Connect with matches living in your city, district or overseas',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Country
          OutlinedDropdownField(
            label: 'Residing Country',
            valueText: reg.country,
            onTap: _selectCountry,
            isRequired: true,
          ),
          const SizedBox(height: 18),

          // State
          OutlinedDropdownField(
            label: 'Residing State',
            valueText: reg.state,
            onTap: _selectState,
            isRequired: true,
          ),
          const SizedBox(height: 18),

          // District
          OutlinedDropdownField(
            label: 'District',
            valueText: _getDistrictLabel(reg.district),
            onTap: _selectDistrict,
            isRequired: true,
          ),
          const SizedBox(height: 18),

          // City
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City / Town',
              hintText: 'e.g. Puducherry, Oulgaret, Heritage Town, Karaikal',
            ),
            onChanged: (val) {
              ref.read(registrationProvider.notifier).updateLocation(city: val.trim());
            },
          ),
          const SizedBox(height: 18),

          // Citizenship
          TextField(
            controller: _citizenshipController,
            decoration: const InputDecoration(
              labelText: 'Citizenship',
              hintText: 'e.g. Indian, French, etc.',
            ),
            onChanged: (val) {
              ref.read(registrationProvider.notifier).updateLocation(citizenship: val.trim());
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
