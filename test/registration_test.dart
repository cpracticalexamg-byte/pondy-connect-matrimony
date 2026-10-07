import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pondy_connect_matrimony/features/registration/providers/registration_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('RegistrationState validates legal marriage age correctly', () {
    const maleUnderage = RegistrationState(
      gender: 'Male',
      birthYear: 2008, // 18 years old in 2026
      birthMonth: 1,
      birthDay: 1,
    );
    expect(maleUnderage.isLegalAgeValid(), isFalse);

    const maleLegal = RegistrationState(
      gender: 'Male',
      birthYear: 2004, // 22 years old in 2026
      birthMonth: 1,
      birthDay: 1,
    );
    expect(maleLegal.isLegalAgeValid(), isTrue);

    const femaleUnderage = RegistrationState(
      gender: 'Female',
      birthYear: 2010, // 16 years old in 2026
      birthMonth: 1,
      birthDay: 1,
    );
    expect(femaleUnderage.isLegalAgeValid(), isFalse);

    const femaleLegal = RegistrationState(
      gender: 'Female',
      birthYear: 2007, // 19 years old in 2026
      birthMonth: 1,
      birthDay: 1,
    );
    expect(femaleLegal.isLegalAgeValid(), isTrue);
  });

  test('Bio content moderation rejects phone numbers, emails and URLs', () {
    final container = ProviderContainer();
    final notifier = container.read(registrationProvider.notifier);

    // Too short
    expect(notifier.validateBio('Short bio'), contains('at least 30 characters'));

    // Valid bio
    const validBio = 'Hello, I am working in Puducherry as a software engineer. Looking for an understanding partner.';
    expect(notifier.validateBio(validBio), isNull);

    // Bio with phone number
    const phoneBio = 'Contact me at 9840012345 or call my father directly for horoscope details.';
    expect(notifier.validateBio(phoneBio), contains('Phone numbers are not allowed'));

    // Bio with email
    const emailBio = 'Please write to me at test.user@gmail.com for more photos and family details.';
    expect(notifier.validateBio(emailBio), contains('Email addresses are not allowed'));

    // Bio with URL
    const urlBio = 'You can see my portfolio and photos at https://myprofile.com/photos here.';
    expect(notifier.validateBio(urlBio), contains('Web links/URLs are not allowed'));
  });

  test('Smart validation engine flags contradictory details', () {
    const contradictoryState = RegistrationState(
      education: 'be_btech',
      employmentType: 'business',
      occupation: 'doctor',
    );
    expect(contradictoryState.checkInconsistencies(), contains('Occupation is Doctor'));

    const unemployedWithIncome = RegistrationState(
      employmentType: 'not_working',
      annualIncomeRange: '10_to_15_lakhs',
    );
    expect(unemployedWithIncome.checkInconsistencies(), contains('Employment is "Not Working"'));
  });
}
