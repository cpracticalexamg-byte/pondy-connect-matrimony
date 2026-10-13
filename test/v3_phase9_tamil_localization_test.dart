import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pondy_connect_matrimony/core/theme/app_typography.dart';
import 'package:pondy_connect_matrimony/core/widgets/app_bar_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    AppTypography.disableGoogleFontsInTests = true;
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 9: Tamil Localization & Parity Tests (§7)', () {
    test('ARB Key Parity: Every key in app_en.arb has a valid translation in app_ta.arb', () {
      final enFile = File('lib/core/l10n/arb/app_en.arb');
      final taFile = File('lib/core/l10n/arb/app_ta.arb');

      expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');
      expect(taFile.existsSync(), isTrue, reason: 'app_ta.arb must exist');

      final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      final taJson = jsonDecode(taFile.readAsStringSync()) as Map<String, dynamic>;

      // Filter out meta keys like @@locale or @keyName
      final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();
      final taKeys = taJson.keys.where((k) => !k.startsWith('@')).toSet();

      final missingInTa = enKeys.difference(taKeys);
      final extraInTa = taKeys.difference(enKeys);

      expect(
        missingInTa,
        isEmpty,
        reason: 'The following keys are in app_en.arb but missing in app_ta.arb: $missingInTa',
      );
      expect(
        extraInTa,
        isEmpty,
        reason: 'The following keys are in app_ta.arb but not in app_en.arb: $extraInTa',
      );

      // Verify no empty translations
      for (final key in enKeys) {
        final enVal = enJson[key];
        final taVal = taJson[key];
        expect(enVal, isNotNull);
        expect(taVal, isNotNull);
        if (enVal is String) {
          expect(enVal.trim().isNotEmpty, isTrue, reason: 'Key $key has empty English translation');
        }
        if (taVal is String) {
          expect(taVal.trim().isNotEmpty, isTrue, reason: 'Key $key has empty Tamil translation');
        }
      }
    });

    test('Verbatim Tamil Matrimony Reference Strings (§7)', () {
      final taFile = File('lib/core/l10n/arb/app_ta.arb');
      final taJson = jsonDecode(taFile.readAsStringSync()) as Map<String, dynamic>;

      // §7 Verbatim strings
      expect(taJson['navHome'], equals('முகப்பு'));
      expect(taJson['navMatches'], equals('வரன்கள்'));
      expect(taJson['navInterests'], equals('விருப்பங்கள்'));
      expect(taJson['navMessages'], equals('மெசேஜ்கள்'));
      expect(taJson['navUpgrade'], equals('அப்கிரேடு'));
      expect(taJson['tabRegular'], equals('ரெகுலர்'));
      expect(taJson['tabPrime'], equals('ப்ரைம்'));
      expect(taJson['freeMember'], equals('இலவச சேவை உறுப்பினர்'));
      expect(taJson['allMatches'], equals('அனைத்து வரன்கள்'));
      expect(taJson['viewAllMatches'], equals('அனைவரையும் பார்க்கவும்'));
      expect(taJson['ageYears'], equals('வயது'));
      expect(taJson['matchesMatchingPreferences'], equals('உங்கள் விருப்பங்களுடன் பொருந்தும் வரன்கள்'));
    });

    test('Tamil Typography line-height is at least 1.35 to prevent glyph clipping', () {
      final titleLargeTa = AppTypography.titleLarge(isTamil: true);
      final sectionTitleTa = AppTypography.sectionTitle(isTamil: true);
      final fieldTextTa = AppTypography.fieldText(isTamil: true);
      final bodyMediumTa = AppTypography.bodyMedium(isTamil: true);
      final helperTa = AppTypography.helper(isTamil: true);

      expect(titleLargeTa.height, greaterThanOrEqualTo(1.35));
      expect(sectionTitleTa.height, greaterThanOrEqualTo(1.35));
      expect(fieldTextTa.height, greaterThanOrEqualTo(1.35));
      expect(bodyMediumTa.height, greaterThanOrEqualTo(1.35));
      expect(helperTa.height, greaterThanOrEqualTo(1.35));
    });

    testWidgets('LanguageToggleButton toggles locale between en and ta', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LanguageToggleButton(),
              ),
            ),
          ),
        ),
      );

      // Initially shows 'அ' and 'தமிழ்' to allow switching to Tamil
      expect(find.text('அ'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.byType(LanguageToggleButton));
      await tester.pumpAndSettle();

      // Now active locale is Tamil, button shows 'A' and 'ENG' to switch back
      expect(find.text('A'), findsOneWidget);
      expect(find.text('ENG'), findsOneWidget);

      // Tap again to switch back to English
      await tester.tap(find.byType(LanguageToggleButton));
      await tester.pumpAndSettle();

      expect(find.text('அ'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
    });

    testWidgets('1.3x Text Scale layout test for Tamil strings without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.3),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'உங்கள் விருப்பங்களுடன் பொருந்தும் வரன்கள்',
                        style: AppTypography.titleLarge(isTamil: true),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '100% தனியுரிமைக் கட்டுப்பாடு — உங்கள் புகைப்படத்தை யார் பார்க்கலாம் என்பதை நீங்கள் தேர்வுசெய்யலாம்',
                        style: AppTypography.bodyMedium(isTamil: true),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text('அனைத்து வரன்கள்', style: AppTypography.helper(isTamil: true))),
                          Chip(label: Text('என் தொழில் போன்ற வரன்கள்', style: AppTypography.helper(isTamil: true))),
                          Chip(label: Text('சரிபார்க்கப்பட்டவை', style: AppTypography.helper(isTamil: true))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('உங்கள் விருப்பங்களுடன் பொருந்தும் வரன்கள்'), findsOneWidget);
    });
  });
}
