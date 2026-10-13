class CsvSchema {
  static const int currentVersion = 3;

  // Table name constants
  static const String metaTable = 'schema_meta';
  static const String usersTable = 'users';
  static const String userSessionsTable = 'user_sessions';
  static const String otpRequestsTable = 'otp_requests';
  static const String profilesTable = 'profiles';
  static const String profileHoroscopesTable = 'profile_horoscopes';
  static const String profileFamilyTable = 'profile_family';
  static const String profileLifestyleTable = 'profile_lifestyle';
  static const String profileEduCareerTable = 'profile_education_career';
  static const String profileLocationTable = 'profile_location';
  static const String profileLanguagesTable = 'profile_languages_known';
  static const String profileHobbiesTable = 'profile_hobbies';
  static const String photosTable = 'photos';
  static const String horoscopeFilesTable = 'horoscope_files';
  static const String partnerPrefsTable = 'partner_preferences';
  static const String partnerPrefValuesTable = 'partner_preference_values';
  static const String interestsTable = 'interests';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
  static const String shortlistsTable = 'shortlists';
  static const String viewsTable = 'profile_views';
  static const String contactViewsTable = 'contact_views';
  static const String blocksTable = 'blocks';
  static const String reportsTable = 'reports';
  static const String notificationsTable = 'notifications';
  static const String plansTable = 'plans';
  static const String subscriptionsTable = 'subscriptions';
  static const String paymentsTable = 'payments';
  static const String verificationRequestsTable = 'verification_requests';
  static const String successStoriesTable = 'success_stories';
  static const String helpTicketsTable = 'help_tickets';
  static const String consentsTable = 'consents';
  static const String appSettingsTable = 'app_settings';
  static const String auditLogTable = 'audit_log';

  // V3 New Tables
  static const String dailyRecommendationsTable = 'daily_recommendations';
  static const String hiddenProfilesTable = 'hidden_profiles';
  static const String profileLocationsTable = 'profile_locations';
  static const String userFilterStateTable = 'user_filter_state';
  static const String userFilterOccupationsTable = 'user_filter_occupations';
  static const String savedSearchesTable = 'saved_searches';
  static const String fieldVisibilityTable = 'field_visibility';
  static const String exclusiveBoostsTable = 'exclusive_boosts';
  static const String invoicesTable = 'invoices';
  static const String profilePhotoRequestsTable = 'profile_photo_requests';
  static const String appOpenLogTable = 'app_open_log';
  static const String notificationSettingsTable = 'notification_settings';

  // Backwards compatibility aliases
  static const String viewsTableV1 = 'views';
  static const String partnerPrefsTableV1 = 'partner_prefs';
  static const String otpCodesTableV1 = 'otp_codes';
  static const String otpCodesTable = otpRequestsTable;

  static List<String> get allTables => tableColumns.keys.toList();

  static const Map<String, List<String>> tableColumns = {
    metaTable: ['key', 'value', 'created_at', 'updated_at'],
    usersTable: [
      'user_id', 'mobile', 'email', 'password_hash', 'salt', 'status',
      'is_verified', 'is_sample', 'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    userSessionsTable: [
      'session_id', 'user_id', 'token_hash', 'device_info', 'ip_address',
      'created_at', 'expires_at', 'revoked_at'
    ],
    otpRequestsTable: [
      'request_id', 'mobile', 'otp_hash', 'attempts', 'is_verified',
      'lockout_until', 'expires_at', 'created_at'
    ],
    profilesTable: [
      'profile_id', 'user_id', 'matrimony_id', 'name', 'gender', 'dob', 'age',
      'height_cm', 'weight_kg', 'body_type_id', 'complexion_id', 'blood_group_id',
      'physical_status_id', 'disability_type_id', 'marital_status_id', 'no_of_children',
      'children_living_with_me', 'mother_tongue_id', 'religion_id', 'division_id',
      'caste_id', 'sub_caste_id', 'gothram_id', 'willing_other_caste',
      'about_me', 'profile_photo_privacy', 'profile_source', 'is_sample',
      'completeness_pct', 'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    profileHoroscopesTable: [
      'horoscope_id', 'profile_id', 'nakshatra_id', 'padam', 'rasi_id', 'lagnam_id',
      'dosham_id', 'dasa_id', 'dasa_balance_years', 'dasa_balance_months', 'dasa_balance_days',
      'time_of_birth', 'place_of_birth', 'chart_raasi_json', 'chart_amsam_json',
      'horoscope_match_required', 'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    profileFamilyTable: [
      'family_id', 'profile_id', 'family_status_id', 'family_type_id', 'family_values_id',
      'father_occupation_id', 'mother_occupation_id', 'brothers_count', 'brothers_married',
      'sisters_count', 'sisters_married', 'native_place', 'parents_status', 'ancestral_origin',
      'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    profileLifestyleTable: [
      'lifestyle_id', 'profile_id', 'diet_id', 'smoking_id', 'drinking_id',
      'interests_notes', 'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    profileEduCareerTable: [
      'edu_career_id', 'profile_id', 'education_level_id', 'education_degree_id', 'degree_detail',
      'institution', 'employment_type_id', 'occupation_category_id', 'occupation_id',
      'employer', 'job_location', 'currency_id', 'annual_income_range_id',
      'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    profileLocationTable: [
      'location_id', 'profile_id', 'country_id', 'state_id', 'district_id', 'city_id',
      'citizenship_id', 'residency_status_id', 'native_district_id', 'willing_to_relocate',
      'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    profileLanguagesTable: [
      'id', 'profile_id', 'language_id', 'can_read', 'can_write', 'can_speak', 'created_at'
    ],
    profileHobbiesTable: [
      'id', 'profile_id', 'hobby_id', 'created_at'
    ],
    photosTable: [
      'photo_id', 'profile_id', 'blob_path', 'is_primary', 'privacy',
      'sort_order', 'is_sample', 'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    horoscopeFilesTable: [
      'file_id', 'profile_id', 'blob_path', 'file_type', 'privacy',
      'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    partnerPrefsTable: [
      'pref_id', 'profile_id', 'age_min', 'age_max', 'height_min_cm', 'height_max_cm',
      'income_min_id', 'diet_id', 'smoking_id', 'drinking_id', 'star_match_required',
      'dosham_pref_id', 'photo_only', 'verified_only',
      'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    partnerPrefValuesTable: [
      'id', 'pref_id', 'field_name', 'master_id', 'created_at'
    ],
    interestsTable: [
      'interest_id', 'from_profile_id', 'to_profile_id', 'status', 'message',
      'sent_at', 'responded_at', 'deleted_at', 'row_version'
    ],
    conversationsTable: [
      'conversation_id', 'profile_a', 'profile_b', 'last_message_at',
      'created_at', 'updated_at', 'deleted_at', 'row_version'
    ],
    messagesTable: [
      'message_id', 'conversation_id', 'from_profile_id', 'to_profile_id', 'text',
      'msg_type', 'sent_at', 'delivered_at', 'read_at', 'deleted_at', 'row_version'
    ],
    shortlistsTable: [
      'id', 'profile_id', 'target_profile_id', 'created_at'
    ],
    viewsTable: [
      'id', 'viewer_profile_id', 'viewed_profile_id', 'viewed_at'
    ],
    contactViewsTable: [
      'id', 'viewer_profile_id', 'viewed_profile_id', 'quota_window_id', 'viewed_at'
    ],
    blocksTable: [
      'id', 'blocker_profile_id', 'blocked_profile_id', 'created_at'
    ],
    reportsTable: [
      'report_id', 'reporter_profile_id', 'reported_profile_id', 'reason_id',
      'details', 'status', 'created_at', 'resolved_at'
    ],
    notificationsTable: [
      'notif_id', 'profile_id', 'notif_type', 'title', 'body', 'payload',
      'is_read', 'created_at', 'deleted_at'
    ],
    plansTable: [
      'plan_id', 'code', 'name', 'tier', 'price_inr', 'list_price',
      'promo_start', 'promo_end', 'duration_days', 'duration_months',
      'contact_view_limit', 'daily_contact_cap', 'unlimited_messages',
      'unlimited_horoscope', 'verified_photo_access', 'is_best_value',
      'is_exclusive', 'ends_on_marriage', 'features_json', 'sort_order', 'is_active'
    ],
    subscriptionsTable: [
      'subscription_id', 'user_id', 'plan_id', 'started_at', 'expires_at',
      'payment_ref', 'status', 'created_at', 'updated_at'
    ],
    paymentsTable: [
      'payment_id', 'user_id', 'plan_id', 'amount_inr', 'currency', 'gateway',
      'gateway_ref', 'status', 'created_at'
    ],
    verificationRequestsTable: [
      'request_id', 'profile_id', 'id_type', 'masked_last_four', 'verification_status',
      'submitted_at', 'reviewed_at', 'reviewer_notes'
    ],
    successStoriesTable: [
      'story_id', 'groom_name', 'bride_name', 'wedding_date', 'location',
      'story', 'photo_blob_path', 'is_sample', 'is_approved', 'created_at'
    ],
    helpTicketsTable: [
      'ticket_id', 'user_id', 'topic_id', 'subject', 'message',
      'status', 'created_at', 'resolved_at'
    ],
    consentsTable: [
      'consent_id', 'user_id', 'terms_version', 'privacy_version',
      'sensitive_data_consent', 'photo_visibility_consent', 'accepted_at'
    ],
    appSettingsTable: [
      'key', 'value', 'updated_at'
    ],
    auditLogTable: [
      'log_id', 'actor_id', 'action', 'entity', 'entity_id', 'details', 'created_at'
    ],
    dailyRecommendationsTable: [
      'rec_id', 'user_profile_id', 'profile_id', 'rec_date', 'position', 'status', 'acted_at'
    ],
    hiddenProfilesTable: [
      'hider_profile_id', 'hidden_profile_id', 'created_at'
    ],
    profileLocationsTable: [
      'profile_id', 'lat_coarse', 'lng_coarse', 'geohash5', 'share_mode', 'source', 'updated_at'
    ],
    userFilterStateTable: [
      'user_id', 'scope', 'filters_json_normalised', 'sort_code', 'occupation_codes', 'updated_at'
    ],
    userFilterOccupationsTable: [
      'id', 'user_id', 'scope', 'occupation_code', 'created_at'
    ],
    savedSearchesTable: [
      'search_id', 'user_profile_id', 'name', 'filters_json', 'created_at'
    ],
    fieldVisibilityTable: [
      'field_code', 'free', 'gold', 'prime_gold', 'till_u_marry'
    ],
    exclusiveBoostsTable: [
      'boost_id', 'profile_id', 'plan_id', 'starts_at', 'ends_at'
    ],
    invoicesTable: [
      'invoice_id', 'payment_id', 'user_profile_id', 'invoice_number',
      'base_amount', 'gst_amount', 'total_amount', 'buyer_state', 'created_at'
    ],
    profilePhotoRequestsTable: [
      'request_id', 'requester_profile_id', 'target_profile_id', 'status', 'created_at', 'updated_at'
    ],
    appOpenLogTable: [
      'log_id', 'user_profile_id', 'open_date', 'opened_at'
    ],
    notificationSettingsTable: [
      'user_profile_id', 'daily_recommendations', 'interests', 'messages',
      'shortlists', 'profile_views', 'marketing', 'updated_at'
    ],
  };
}
