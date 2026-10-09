import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/outlined_dropdown_field.dart';
import '../../../core/widgets/picker_sheet.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/step_scaffold.dart';
import '../../../data/repositories/master_data_repository.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../providers/registration_provider.dart';

class Step4ProfessionalScreen extends ConsumerStatefulWidget {
  const Step4ProfessionalScreen({super.key});

  @override
  ConsumerState<Step4ProfessionalScreen> createState() => _Step4ProfessionalScreenState();
}

class _Step4ProfessionalScreenState extends ConsumerState<Step4ProfessionalScreen> {
  List<MasterItem> _educations = [];
  List<MasterItem> _occupations = [];
  List<MasterItem> _employmentTypes = [];
  List<MasterItem> _incomeRanges = [];
  late final TextEditingController _educationDetailController;
  late final TextEditingController _employerController;

  @override
  void initState() {
    super.initState();
    final reg = ref.read(registrationProvider);
    _educationDetailController = TextEditingController(text: reg.educationDetail);
    _employerController = TextEditingController(text: reg.employer);
    _loadMasters();
  }

  @override
  void dispose() {
    _educationDetailController.dispose();
    _employerController.dispose();
    super.dispose();
  }

  Future<void> _loadMasters() async {
    final repo = MasterDataRepository.instance;
    final edu = await repo.getEducationLevels();
    final occ = await repo.getOccupations();
    final emp = await repo.getEmploymentTypes();
    final inc = await repo.getIncomeRanges();

    if (mounted) {
      setState(() {
        _educations = edu;
        _occupations = occ;
        _employmentTypes = emp;
        _incomeRanges = inc;
      });
    }
  }

  String _getLabel(List<MasterItem> list, String id, {String fallback = 'Select'}) {
    for (final item in list) {
      if (item.id == id) return item.nameEn;
    }
    return fallback;
  }

  void _selectEducation() async {
    final options = _educations.map((e) => PickerOption<String>(
      value: e.id,
      title: e.nameEn,
      subtitle: e.extras['category'] as String?,
    )).toList();

    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Education Level',
      options: options,
      showSearch: true,
      selectedValue: reg.education,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateProfessional(education: chosen);
    }
  }

  void _selectOccupation() async {
    final options = _occupations.map((o) => PickerOption<String>(
      value: o.id,
      title: o.nameEn,
      subtitle: o.extras['category'] as String?,
    )).toList();

    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Occupation',
      options: options,
      showSearch: true,
      selectedValue: reg.occupation,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateProfessional(occupation: chosen);
    }
  }

  void _selectIncome() async {
    final options = _incomeRanges.map((i) => PickerOption<String>(
      value: i.id,
      title: i.nameEn,
    )).toList();

    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<String>(
      context: context,
      title: 'Select Annual Income',
      options: options,
      selectedValue: reg.annualIncomeRange,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updateProfessional(annualIncomeRange: chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final reg = ref.watch(registrationProvider);
    final prefix = auth.relationPrefix;

    final isNotWorking = reg.employmentType == 'not_working' || reg.employmentType == 'student';
    final isStepValid = reg.education.isNotEmpty && reg.employmentType.isNotEmpty;

    return StepScaffold(
      title: 'Professional Details (4/5)',
      progress: 0.70,
      showTeaser: true,
      matchCount: reg.realTimeMatchCount,
      isNextEnabled: isStepValid,
      onNext: () {
        context.push('/register/step5');
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${prefix}Education & Career Details',
            style: AppTypography.titleLarge(),
          ),
          const SizedBox(height: 6),
          Text(
            'Professional background is one of the highest compatibility factors',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Education
          OutlinedDropdownField(
            label: '${prefix}Highest Education',
            valueText: _getLabel(_educations, reg.education),
            onTap: _selectEducation,
            isRequired: true,
          ),
          const SizedBox(height: 18),

          // Education detail
          TextField(
            controller: _educationDetailController,
            decoration: const InputDecoration(
              labelText: 'College / Degree Specialization (Optional)',
              hintText: 'e.g. Pondicherry Engineering College (PEC), Computer Science',
            ),
            onChanged: (val) {
              ref.read(registrationProvider.notifier).updateProfessional(educationDetail: val.trim());
            },
          ),
          const SizedBox(height: 24),

          // Employment Type (radio-chips)
          Text(
            'Employment Sector',
            style: AppTypography.sectionTitle(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _employmentTypes.map((emp) {
              final isSelected = reg.employmentType == emp.id;
              return PillChip(
                label: emp.nameEn,
                isSelected: isSelected,
                onTap: () {
                  ref.read(registrationProvider.notifier).updateProfessional(
                    employmentType: emp.id,
                    annualIncomeRange: (emp.id == 'not_working' || emp.id == 'student') ? 'no_income' : reg.annualIncomeRange,
                  );
                },
              );
            }).toList(),
          ),

          // Occupation and Income (hidden when not working)
          if (!isNotWorking) ...[
            const SizedBox(height: 24),
            OutlinedDropdownField(
              label: '${prefix}Occupation',
              valueText: _getLabel(_occupations, reg.occupation),
              onTap: _selectOccupation,
              isRequired: true,
            ),
            const SizedBox(height: 18),

            TextField(
              controller: _employerController,
              decoration: const InputDecoration(
                labelText: 'Employer / Company Name (Optional)',
                hintText: 'e.g. JIPMER, TCS, HCL, Govt of Puducherry, etc.',
              ),
              onChanged: (val) {
                ref.read(registrationProvider.notifier).updateProfessional(employer: val.trim());
              },
            ),
            const SizedBox(height: 18),

            OutlinedDropdownField(
              label: 'Annual Income',
              valueText: _getLabel(_incomeRanges, reg.annualIncomeRange),
              onTap: _selectIncome,
              isRequired: true,
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
