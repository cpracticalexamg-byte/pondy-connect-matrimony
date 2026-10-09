import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/step_scaffold.dart';
import '../../../data/repositories/master_data_repository.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../providers/registration_provider.dart';

class Step5AdditionalScreen extends ConsumerStatefulWidget {
  const Step5AdditionalScreen({super.key});

  @override
  ConsumerState<Step5AdditionalScreen> createState() => _Step5AdditionalScreenState();
}

class _Step5AdditionalScreenState extends ConsumerState<Step5AdditionalScreen> {
  List<MasterItem> _familyStatuses = [];
  List<MasterItem> _familyTypes = [];
  List<MasterItem> _familyValues = [];
  List<MasterItem> _diets = [];
  late final TextEditingController _fatherOccupationController;
  late final TextEditingController _motherOccupationController;

  @override
  void initState() {
    super.initState();
    final reg = ref.read(registrationProvider);
    _fatherOccupationController = TextEditingController(text: reg.fatherOccupation);
    _motherOccupationController = TextEditingController(text: reg.motherOccupation);
    _loadMasters();
  }

  @override
  void dispose() {
    _fatherOccupationController.dispose();
    _motherOccupationController.dispose();
    super.dispose();
  }

  Future<void> _loadMasters() async {
    final repo = MasterDataRepository.instance;
    final stat = await repo.getFamilyStatus();
    final type = await repo.getFamilyType();
    final val = await repo.getFamilyValues();
    final diet = await repo.getDiet();

    if (mounted) {
      setState(() {
        _familyStatuses = stat;
        _familyTypes = type;
        _familyValues = val;
        _diets = diet;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final reg = ref.watch(registrationProvider);
    final prefix = auth.relationPrefix;

    return StepScaffold(
      title: 'Additional Details (5/5)',
      progress: 0.90,
      showTeaser: true,
      matchCount: reg.realTimeMatchCount,
      isNextEnabled: true,
      onNext: () {
        context.push('/register/review');
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${prefix}Family & Lifestyle Details',
            style: AppTypography.titleLarge(),
          ),
          const SizedBox(height: 6),
          Text(
            'Family values and lifestyle compatibility bring long-term happiness',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Family Status (radio-pills)
          Text('Family Status', style: AppTypography.sectionTitle()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _familyStatuses.map((s) {
              final isSelected = reg.familyStatus == s.id;
              return PillChip(
                label: s.nameEn,
                isSelected: isSelected,
                onTap: () {
                  ref.read(registrationProvider.notifier).updateFamily(familyStatus: s.id);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Family Type
          Text('Family Type', style: AppTypography.sectionTitle()),
          const SizedBox(height: 10),
          Row(
            children: _familyTypes.map((t) {
              final isSelected = reg.familyType == t.id;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PillChip(
                  label: t.nameEn,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(registrationProvider.notifier).updateFamily(familyType: t.id);
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Family Values
          Text('Family Values', style: AppTypography.sectionTitle()),
          const SizedBox(height: 10),
          Row(
            children: _familyValues.map((v) {
              final isSelected = reg.familyValues == v.id;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PillChip(
                  label: v.nameEn,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(registrationProvider.notifier).updateFamily(familyValues: v.id);
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Diet
          Text('Diet', style: AppTypography.sectionTitle()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _diets.map((d) {
              final isSelected = reg.diet == d.id;
              return PillChip(
                label: d.nameEn,
                isSelected: isSelected,
                onTap: () {
                  ref.read(registrationProvider.notifier).updateFamily(diet: d.id);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Parents occupation
          TextField(
            controller: _fatherOccupationController,
            decoration: const InputDecoration(
              labelText: "Father's Occupation (Optional)",
              hintText: 'e.g. Business, Retired Govt Employee, Teacher',
            ),
            onChanged: (val) {
              ref.read(registrationProvider.notifier).updateFamily(fatherOccupation: val.trim());
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _motherOccupationController,
            decoration: const InputDecoration(
              labelText: "Mother's Occupation (Optional)",
              hintText: 'e.g. Homemaker, Professor, Bank Officer',
            ),
            onChanged: (val) {
              ref.read(registrationProvider.notifier).updateFamily(motherOccupation: val.trim());
            },
          ),
          const SizedBox(height: 20),

          // Siblings count
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Brothers', style: TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: reg.brothers > 0
                                ? () => ref.read(registrationProvider.notifier).updateFamily(brothers: reg.brothers - 1)
                                : null,
                          ),
                          Text('${reg.brothers}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => ref.read(registrationProvider.notifier).updateFamily(brothers: reg.brothers + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sisters', style: TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: reg.sisters > 0
                                ? () => ref.read(registrationProvider.notifier).updateFamily(sisters: reg.sisters - 1)
                                : null,
                          ),
                          Text('${reg.sisters}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => ref.read(registrationProvider.notifier).updateFamily(sisters: reg.sisters + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
