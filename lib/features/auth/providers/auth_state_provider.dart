import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/profile_model.dart';
import '../../../domain/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return CsvAuthRepository();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return CsvProfileRepository();
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  return AuthStateNotifier(authRepo, profileRepo);
});

class AuthState {
  final UserModel? user;
  final ProfileModel? profile;
  final bool isLoading;
  final String? error;
  final String profileFor;
  final String currentMobile;
  final String? generatedOtp;

  const AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
    this.profileFor = 'Myself',
    this.currentMobile = '',
    this.generatedOtp,
  });

  bool get isAuthenticated => user != null;

  String get relationPrefix {
    switch (profileFor.toLowerCase()) {
      case 'myself':
        return '';
      case 'son':
        return "Son's ";
      case 'daughter':
        return "Daughter's ";
      case 'brother':
        return "Brother's ";
      case 'sister':
        return "Sister's ";
      case 'friend':
        return "Friend's ";
      case 'relative':
        return "Relative's ";
      default:
        return "$profileFor's ";
    }
  }

  AuthState copyWith({
    UserModel? user,
    ProfileModel? profile,
    bool? isLoading,
    String? error,
    String? profileFor,
    String? currentMobile,
    String? generatedOtp,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profileFor: profileFor ?? this.profileFor,
      currentMobile: currentMobile ?? this.currentMobile,
      generatedOtp: generatedOtp ?? this.generatedOtp,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final ProfileRepository _profileRepo;

  AuthStateNotifier(this._authRepo, this._profileRepo) : super(const AuthState()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    state = state.copyWith(isLoading: true);
    final user = await _authRepo.getCurrentUser();
    if (user != null) {
      final profile = await _profileRepo.getProfileByUserId(user.userId);
      state = state.copyWith(user: user, profile: profile, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void setProfileFor(String relation) {
    state = state.copyWith(profileFor: relation);
  }

  void setMobile(String mobile) {
    state = state.copyWith(currentMobile: mobile);
  }

  Future<String?> requestOtp(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final otp = await _authRepo.requestOtp(mobile);
      state = state.copyWith(
        isLoading: false,
        currentMobile: mobile,
        generatedOtp: otp,
      );
      return otp;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> verifyOtpAndRegister(String mobile, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isValid = await _authRepo.verifyOtp(mobile, otp);
      if (!isValid) {
        state = state.copyWith(isLoading: false, error: 'Invalid or expired OTP. Please try again.');
        return false;
      }

      final user = await _authRepo.registerOrGet(mobile, state.profileFor);
      final profile = await _profileRepo.getProfileByUserId(user.userId);
      state = state.copyWith(
        user: user,
        profile: profile,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> loginWithPassword(String mobile, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepo.loginWithPassword(mobile, password);
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Invalid mobile number or password');
        return false;
      }
      final profile = await _profileRepo.getProfileByUserId(user.userId);
      state = state.copyWith(
        user: user,
        profile: profile,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = const AuthState();
  }

  Future<bool> deleteAccount({required String reason}) async {
    final userId = state.user?.userId;
    if (userId == null) return false;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepo.deleteAccount(userId: userId, reason: reason);
      state = const AuthState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
