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

  /// No description provided for @navInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get navInterests;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get navUpgrade;

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

  /// No description provided for @tabRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get tabRegular;

  /// No description provided for @tabPrime.
  ///
  /// In en, this message translates to:
  /// **'Prime'**
  String get tabPrime;

  /// No description provided for @freeMember.
  ///
  /// In en, this message translates to:
  /// **'Free Member'**
  String get freeMember;

  /// No description provided for @goldMember.
  ///
  /// In en, this message translates to:
  /// **'Gold Member'**
  String get goldMember;

  /// No description provided for @primeGoldMember.
  ///
  /// In en, this message translates to:
  /// **'Prime Gold Member'**
  String get primeGoldMember;

  /// No description provided for @primeTillUMarry.
  ///
  /// In en, this message translates to:
  /// **'Prime – Till U Marry'**
  String get primeTillUMarry;

  /// No description provided for @allMatches.
  ///
  /// In en, this message translates to:
  /// **'All matches'**
  String get allMatches;

  /// No description provided for @viewAllMatches.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAllMatches;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get ageYears;

  /// No description provided for @matchesMatchingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Matches based on your preferences'**
  String get matchesMatchingPreferences;

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

  /// No description provided for @shortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get shortlisted;

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

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

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

  /// No description provided for @becomePaidMember.
  ///
  /// In en, this message translates to:
  /// **'Become a paid member now!'**
  String get becomePaidMember;

  /// No description provided for @regularPacks.
  ///
  /// In en, this message translates to:
  /// **'Regular Packs'**
  String get regularPacks;

  /// No description provided for @exclusives.
  ///
  /// In en, this message translates to:
  /// **'Exclusives'**
  String get exclusives;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @dontShow.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Show'**
  String get dontShow;

  /// No description provided for @dailyRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Recommendation'**
  String get dailyRecommendationTitle;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// No description provided for @newRecommendationsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'New recommendations tomorrow'**
  String get newRecommendationsTomorrow;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @newlyJoined.
  ///
  /// In en, this message translates to:
  /// **'Newly joined'**
  String get newlyJoined;

  /// No description provided for @notSeen.
  ///
  /// In en, this message translates to:
  /// **'Not seen'**
  String get notSeen;

  /// No description provided for @profilesWithPhoto.
  ///
  /// In en, this message translates to:
  /// **'Profiles with photo'**
  String get profilesWithPhoto;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @sameProfessionAsMe.
  ///
  /// In en, this message translates to:
  /// **'Same profession as me'**
  String get sameProfessionAsMe;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @saveThisSearch.
  ///
  /// In en, this message translates to:
  /// **'Save this search'**
  String get saveThisSearch;

  /// No description provided for @upgradeToPaidMembership.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Paid Membership'**
  String get upgradeToPaidMembership;

  /// No description provided for @viewContact.
  ///
  /// In en, this message translates to:
  /// **'View contact'**
  String get viewContact;

  /// No description provided for @upgradeToView.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to view'**
  String get upgradeToView;

  /// No description provided for @privacyAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Privacy & location'**
  String get privacyAndLocation;

  /// No description provided for @partnerPreferences.
  ///
  /// In en, this message translates to:
  /// **'Partner preferences'**
  String get partnerPreferences;

  /// No description provided for @hiddenProfiles.
  ///
  /// In en, this message translates to:
  /// **'Hidden profiles'**
  String get hiddenProfiles;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @stepOneOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 1/2'**
  String get stepOneOfTwo;

  /// No description provided for @stepTwoOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 2/2'**
  String get stepTwoOfTwo;

  /// No description provided for @mandatoryPhotoPrimeTitle.
  ///
  /// In en, this message translates to:
  /// **'It is mandatory to add your photo to view Prime matches.'**
  String get mandatoryPhotoPrimeTitle;

  /// No description provided for @mandatoryPhotoPrimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Just two more steps before you view Prime matches.'**
  String get mandatoryPhotoPrimeSubtitle;

  /// No description provided for @addYourPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Your Photo'**
  String get addYourPhoto;

  /// No description provided for @verifyYourId.
  ///
  /// In en, this message translates to:
  /// **'Verify your ID'**
  String get verifyYourId;

  /// No description provided for @privacyControlGuaranteed.
  ///
  /// In en, this message translates to:
  /// **'100% privacy control — choose who can view your photo'**
  String get privacyControlGuaranteed;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @addPhotoLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll add photo later'**
  String get addPhotoLater;

  /// No description provided for @sampleProfile.
  ///
  /// In en, this message translates to:
  /// **'Sample profile'**
  String get sampleProfile;

  /// No description provided for @sampleProfileDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a sample profile for demonstration.'**
  String get sampleProfileDemoNotice;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;
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
