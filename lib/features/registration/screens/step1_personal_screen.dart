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

class Step1PersonalScreen extends ConsumerStatefulWidget {
  const Step1PersonalScreen({super.key});

  @override
  ConsumerState<Step1PersonalScreen> createState() => _Step1PersonalScreenState();
}

class _Step1PersonalScreenState extends ConsumerState<Step1PersonalScreen> {
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _physicalStatuses = ['Normal', 'Physically challenged'];
  final List<String> _maritalStatuses = [
    'never_married',
    'widower',
    'divorced',
    'awaiting_divorce',
    'annulled',
  ];

  final Map<String, String> _maritalStatusLabels = {
    'never_married': 'Never Married',
    'widower': 'Widow / Widower',
    'divorced': 'Divorced',
    'awaiting_divorce': 'Awaiting Divorce',
    'annulled': 'Annulled',
  };

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<MasterItem> _heightList = [];

  @override
  void initState() {
    super.initState();
    _loadHeights();
  }

  Future<void> _loadHeights() async {
    final list = await MasterDataRepository.instance.getHeights();
    if (mounted) {
      setState(() {
        _heightList = list;
      });
    }
  }

  String _getHeightDisplay(int cm) {
    for (final item in _heightList) {
      if (item.extras['cm'] == cm) {
        return item.nameEn;
      }
    }
    return '$cm cm';
  }

  void _selectHeight() async {
    final options = _heightList.map((h) => PickerOption<int>(
      value: h.extras['cm'] as int,
      title: h.nameEn,
    )).toList();

    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<int>(
      context: context,
      title: 'Select Height',
      options: options,
      selectedValue: reg.heightCm,
    );

    if (chosen != null) {
      ref.read(registrationProvider.notifier).updatePersonal(heightCm: chosen);
    }
  }

  void _selectDay() async {
    final options = List.generate(31, (i) => PickerOption<int>(value: i + 1, title: (i + 1).toString().padLeft(2, '0')));
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<int>(
      context: context,
      title: 'Select Day',
      options: options,
      selectedValue: reg.birthDay,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updatePersonal(birthDay: chosen);
    }
  }

  void _selectMonth() async {
    final options = List.generate(12, (i) => PickerOption<int>(value: i + 1, title: _months[i]));
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<int>(
      context: context,
      title: 'Select Month',
      options: options,
      selectedValue: reg.birthMonth,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updatePersonal(birthMonth: chosen);
    }
  }

  void _selectYear() async {
    final currentYear = DateTime.now().year;
    final options = List.generate(45, (i) {
      final y = currentYear - 18 - i;
      return PickerOption<int>(value: y, title: y.toString());
    });
    final reg = ref.read(registrationProvider);
    final chosen = await PickerSheet.show<int>(
      context: context,
      title: 'Select Year',
      options: options,
      selectedValue: reg.birthYear,
    );
    if (chosen != null) {
      ref.read(registrationProvider.notifier).updatePersonal(birthYear: chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final reg = ref.watch(registrationProvider);
    final prefix = auth.relationPrefix;

    final hasDob = reg.birthDay != null && reg.birthMonth != null && reg.birthYear != null;
    final isAgeValid = reg.isLegalAgeValid();
    final isStepValid = hasDob && isAgeValid;

    return StepScaffold(
      title: 'Personal Details (1/5)',
      progress: 0.20,
      isNextEnabled: isStepValid,
      onNext: () {
        context.push('/register/step2');
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Header
          Text(
            '${prefix}Basic & Physical Details',
            style: AppTypography.titleLarge(),
          ),
          const SizedBox(height: 6),
          Text(
            'Accurate details help us find the best matches',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Gender
          Text(
            'Gender',
            style: AppTypography.sectionTitle(),
          ),
          const SizedBox(height: 10),
          Row(
            children: _genders.map((g) {
              final isSelected = reg.gender == g;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PillChip(
                  label: g,
                  icon: g == 'Male' ? Icons.male_rounded : Icons.female_rounded,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(registrationProvider.notifier).updatePersonal(gender: g);
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 26),

          // Date of Birth
          Text(
            '${prefix}Date of Birth',
            style: AppTypography.sectionTitle(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // DD Pill
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _selectDay,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: reg.birthDay != null ? AppColors.fieldActiveBorder : AppColors.fieldBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      reg.birthDay != null ? reg.birthDay.toString().padLeft(2, '0') : 'DD',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: reg.birthDay != null ? FontWeight.w700 : FontWeight.w500,
                        color: reg.birthDay != null ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Month Pill
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: _selectMonth,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: reg.birthMonth != null ? AppColors.fieldActiveBorder : AppColors.fieldBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      reg.birthMonth != null ? _months[reg.birthMonth! - 1] : 'Month',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: reg.birthMonth != null ? FontWeight.w700 : FontWeight.w500,
                        color: reg.birthMonth != null ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Year Pill (focused green border as in reference app)
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: _selectYear,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: reg.birthYear != null ? AppColors.fieldActiveBorder : AppColors.fieldActiveBorder,
                        width: 1.8,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      reg.birthYear != null ? reg.birthYear.toString() : 'YYYY',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: reg.birthYear != null ? FontWeight.w700 : FontWeight.w600,
                        color: reg.birthYear != null ? AppColors.textPrimary : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Age calculation or error
          if (hasDob) ...[
            const SizedBox(height: 6),
            if (!isAgeValid)
              Text(
                reg.gender == 'Male'
                    ? 'Legal marriage age for male is 21 years or older.'
                    : 'Legal marriage age for female is 18 years or older.',
                style: AppTypography.caption(color: AppColors.errorRed),
              )
            else
              Text(
                'Age: ${reg.calculatedAge} years',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.progressStart,
                ),
              ),
          ],

          const SizedBox(height: 26),

          // Height
          OutlinedDropdownField(
            label: '${prefix}Height',
            valueText: _getHeightDisplay(reg.heightCm),
            onTap: _selectHeight,
          ),

          const SizedBox(height: 24),

          // Physical Status
          Text(
            '${prefix}Physical Status',
            style: AppTypography.sectionTitle(),
          ),
          const SizedBox(height: 10),
          Row(
            children: _physicalStatuses.map((p) {
              final isSelected = reg.physicalStatus == p;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PillChip(
                  label: p,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(registrationProvider.notifier).updatePersonal(physicalStatus: p);
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 26),

          // Marital Status
          Text(
            '${prefix}Marital Status',
            style: AppTypography.sectionTitle(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _maritalStatuses.map((m) {
              final isSelected = reg.maritalStatus == m;
              return PillChip(
                label: _maritalStatusLabels[m] ?? m,
                isSelected: isSelected,
                onTap: () {
                  ref.read(registrationProvider.notifier).updatePersonal(maritalStatus: m);
                },
              );
            }).toList(),
          ),

          // If not never married: show Children options
          if (reg.maritalStatus != 'never_married') ...[
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('No. of Children', style: AppTypography.bodyMedium()),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            onPressed: reg.noOfChildren > 0
                                ? () => ref.read(registrationProvider.notifier).updatePersonal(noOfChildren: reg.noOfChildren - 1)
                                : null,
                          ),
                          Text('${reg.noOfChildren}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () => ref.read(registrationProvider.notifier).updatePersonal(noOfChildren: reg.noOfChildren + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (reg.noOfChildren > 0) ...[
                    const Divider(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Children living with me', style: TextStyle(fontSize: 14)),
                      value: reg.childrenLivingWithMe,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(registrationProvider.notifier).updatePersonal(childrenLivingWithMe: val ?? false);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
