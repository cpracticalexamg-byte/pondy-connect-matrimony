import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pondy Connect Matrimony'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Find your life partner, the Pondy way'**
  String get appTagline;

  /// No description provided for @needHelpCall.
  ///
  /// In en, this message translates to:
  /// **'Need help? Call'**
  String get needHelpCall;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @seeMatches.
  ///
  /// In en, this message translates to:
  /// **'See Matches'**
  String get seeMatches;

  /// No description provided for @addPartnerPreferences.
  ///
  /// In en, this message translates to:
  /// **'Add Partner Preferences'**
  String get addPartnerPreferences;

  /// No description provided for @matchesWaitingForYou.
  ///
  /// In en, this message translates to:
  /// **'{count} Matches Waiting for You'**
  String matchesWaitingForYou(String count);

  /// No description provided for @completeRegistrationNudge.
  ///
  /// In en, this message translates to:
  /// **'Complete your registration and see more matches'**
  String get completeRegistrationNudge;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Personal Details (1/5)'**
  String get step1Title;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Religion Details (2/5)'**
  String get step2Title;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Location Details (3/5)'**
  String get step3Title;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Professional Details (4/5)'**
  String get step4Title;

  /// No description provided for @step5Title.
  ///
  /// In en, this message translates to:
  /// **'Additional Details (5/5)'**
  String get step5Title;

  /// No description provided for @reviewDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & About'**
  String get reviewDetailsTitle;

  /// No description provided for @profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Photo'**
  String get profilePhotoTitle;

  /// No description provided for @profileCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your profile is live!'**
  String get profileCreatedSuccess;

  /// No description provided for @profileIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile ID'**
  String get profileIdLabel;

  /// No description provided for @completeness.
  ///
  /// In en, this message translates to:
  /// **'Completeness'**
  String get completeness;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @dailyRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Daily Recommendations'**
  String get dailyRecommendations;

  /// No description provided for @newMatches.
  ///
  /// In en, this message translates to:
  /// **'New Matches'**
  String get newMatches;

  /// No description provided for @nearbyMatches.
  ///
  /// In en, this message translates to:
  /// **'Nearby Matches'**
  String get nearbyMatches;

  /// No description provided for @premiumMatches.
  ///
  /// In en, this message translates to:
  /// **'Premium Matches'**
  String get premiumMatches;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get recentlyViewed;

  /// No description provided for @shortlistedByYou.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted by You'**
  String get shortlistedByYou;

  /// No description provided for @viewedYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Viewed Your Profile'**
  String get viewedYourProfile;

  /// No description provided for @successStories.
  ///
  /// In en, this message translates to:
  /// **'Success Stories'**
  String get successStories;

  /// No description provided for @sendInterest.
  ///
  /// In en, this message translates to:
  /// **'Send Interest'**
  String get sendInterest;

  /// No description provided for @shortlist.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlist;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @interestsTabReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get interestsTabReceived;

  /// No description provided for @interestsTabSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get interestsTabSent;

  /// No description provided for @interestsTabAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get interestsTabAccepted;

  /// No description provided for @interestsTabDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get interestsTabDeclined;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @membershipPlans.
  ///
  /// In en, this message translates to:
  /// **'Membership Plans'**
  String get membershipPlans;

  /// No description provided for @horoscopePorutham.
  ///
  /// In en, this message translates to:
  /// **'10-Porutham Matching'**
  String get horoscopePorutham;

  /// No description provided for @verifyProfile.
  ///
  /// In en, this message translates to:
  /// **'Verify Profile'**
  String get verifyProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @profileFor.
  ///
  /// In en, this message translates to:
  /// **'Profile created for'**
  String get profileFor;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @verifyAndProceed.
  ///
  /// In en, this message translates to:
  /// **'Verify & Proceed'**
  String get verifyAndProceed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
