import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _localityController;
  late TextEditingController _occupationController;
  late TextEditingController _educationController;
  late TextEditingController _aboutMeController;
  String _maritalStatus = 'Never Married';
  int _heightCm = 165;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(authStateProvider).profile;
    _nameController = TextEditingController(text: p?.name ?? '');
    _cityController = TextEditingController(text: p?.city ?? 'Puducherry');
    _localityController = TextEditingController(text: p?.locality ?? 'Mudaliarpet');
    _occupationController = TextEditingController(text: p?.occupation ?? '');
    _educationController = TextEditingController(text: p?.education ?? '');
    _aboutMeController = TextEditingController(text: p?.aboutMe ?? '');
    _maritalStatus = p?.maritalStatus.isNotEmpty == true ? p!.maritalStatus : 'Never Married';
    _heightCm = p?.heightCm ?? 165;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final authState = ref.read(authStateProvider);
      final p = authState.profile;
      if (p == null) {
        setState(() => _isSaving = false);
        return;
      }

      final updated = ProfileModel(
        profileId: p.profileId,
        userId: p.userId,
        name: _nameController.text.trim(),
        gender: p.gender,
        dob: p.dob,
        age: p.age,
        heightCm: _heightCm,
        physicalStatus: p.physicalStatus,
        maritalStatus: _maritalStatus,
        noOfChildren: p.noOfChildren,
        motherTongue: p.motherTongue,
        religion: p.religion,
        division: p.division,
        caste: p.caste,
        subcaste: p.subcaste,
        willingOtherCaste: p.willingOtherCaste,
        star: p.star,
        rasi: p.rasi,
        dosham: p.dosham,
        gothram: p.gothram,
        country: p.country,
        state: p.state,
        district: p.district,
        city: _cityController.text.trim(),
        locality: _localityController.text.trim(),
        citizenship: p.citizenship,
        education: _educationController.text.trim(),
        educationDetail: p.educationDetail,
        employmentType: p.employmentType,
        occupation: _occupationController.text.trim(),
        employer: p.employer,
        incomeCurrency: p.incomeCurrency,
        annualIncomeRange: p.annualIncomeRange,
        familyStatus: p.familyStatus,
        familyType: p.familyType,
        familyValues: p.familyValues,
        fatherOccupation: p.fatherOccupation,
        motherOccupation: p.motherOccupation,
        brothers: p.brothers,
        sisters: p.sisters,
        diet: p.diet,
        smoking: p.smoking,
        drinking: p.drinking,
        aboutMe: _aboutMeController.text.trim(),
        profilePhotoPrivacy: p.profilePhotoPrivacy,
        completenessPct: 85,
        createdAt: p.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
        isDemo: p.isDemo,
      );

      final profileRepo = ref.read(profileRepoProvider);
      await profileRepo.updateProfile(updated);
      await ref.read(authStateProvider.notifier).checkCurrentUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.successGreen),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              _buildTextField('Full Name', _nameController, (v) => v?.isEmpty == true ? 'Please enter name' : null),
              const SizedBox(height: 12),
              _buildTextField('City / Town', _cityController, null),
              const SizedBox(height: 12),
              _buildTextField('Locality / Neighbourhood', _localityController, null),
              const SizedBox(height: 12),

              const Text('Marital Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _maritalStatus,
                items: ['Never Married', 'Divorced', 'Widowed', 'Separated']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _maritalStatus = v!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),
              _buildSectionTitle('Professional & Education'),
              _buildTextField('Highest Degree / Education', _educationController, null),
              const SizedBox(height: 12),
              _buildTextField('Occupation / Job Title', _occupationController, null),

              const SizedBox(height: 20),
              _buildSectionTitle('About Me & Expectations'),
              TextFormField(
                controller: _aboutMeController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share a few words about your values, personality and partner expectations...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 28),
              if (_isSaving)
                const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
              else
                AppButton(
                  text: 'Save Changes',
                  onPressed: _saveProfile,
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: AppTypography.heading3.copyWith(fontSize: 16)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String? Function(String?)? validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
