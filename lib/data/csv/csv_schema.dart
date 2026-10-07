class CsvSchema {
  static const int currentVersion = 1;

  static const String metaTable = '_meta';
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String photosTable = 'photos';
  static const String partnerPrefsTable = 'partner_prefs';
  static const String interestsTable = 'interests';
  static const String messagesTable = 'messages';
  static const String shortlistsTable = 'shortlists';
  static const String viewsTable = 'views';
  static const String blocksTable = 'blocks';
  static const String reportsTable = 'reports';
  static const String notificationsTable = 'notifications';
  static const String plansTable = 'plans';
  static const String subscriptionsTable = 'subscriptions';
  static const String otpCodesTable = 'otp_codes';
  static const String successStoriesTable = 'success_stories';
  static const String contactViewsTable = 'contact_views';
  static const String helpTicketsTable = 'help_tickets';

  static const Map<String, List<String>> tableColumns = {
    metaTable: ['key', 'value'],
    usersTable: [
      'user_id',
      'mobile',
      'email',
      'password_hash',
      'salt',
      'profile_for',
      'created_at',
      'last_login',
      'status', // active, hidden, deleted
      'plan_id',
      'plan_expiry',
      'is_verified',
      'is_demo',
    ],
    profilesTable: [
      'profile_id',
      'user_id',
      'name',
      'gender',
      'dob',
      'age',
      'height_cm',
      'physical_status',
      'marital_status',
      'no_of_children',
      'mother_tongue',
      'religion',
      'division',
      'caste',
      'subcaste',
      'willing_other_caste',
      'star',
      'rasi',
      'dosham',
      'gothram',
      'country',
      'state',
      'district',
      'city',
      'citizenship',
      'education',
      'education_detail',
      'employment_type',
      'occupation',
      'employer',
      'income_currency',
      'annual_income_range',
      'family_status',
      'family_type',
      'family_values',
      'father_occupation',
      'mother_occupation',
      'brothers',
      'sisters',
      'diet',
      'smoking',
      'drinking',
      'about_me',
      'profile_photo_privacy', // all, premium, on_request
      'completeness_pct',
      'created_at',
      'updated_at',
      'is_demo',
    ],
    photosTable: [
      'photo_id',
      'profile_id',
      'path_or_asset',
      'is_primary',
      'privacy', // all, premium, on_request
      'order',
      'uploaded_at',
    ],
    partnerPrefsTable: [
      'profile_id',
      'age_min',
      'age_max',
      'height_min',
      'height_max',
      'marital_status',
      'religion',
      'division',
      'caste',
      'mother_tongue',
      'education',
      'occupation',
      'income_min',
      'country',
      'state',
      'district',
      'diet',
      'star_match_required',
      'dosham_pref',
    ],
    interestsTable: [
      'interest_id',
      'from_profile',
      'to_profile',
      'status', // sent, accepted, declined, withdrawn
      'message',
      'sent_at',
      'responded_at',
    ],
    messagesTable: [
      'msg_id',
      'thread_id',
      'from_profile',
      'to_profile',
      'text',
      'type', // text, template, image
      'sent_at',
      'delivered_at',
      'read_at',
    ],
    shortlistsTable: [
      'user_profile',
      'target_profile',
      'created_at',
    ],
    viewsTable: [
      'viewer_profile',
      'viewed_profile',
      'viewed_at',
    ],
    blocksTable: [
      'blocker',
      'blocked',
      'created_at',
    ],
    reportsTable: [
      'report_id',
      'reporter',
      'reported',
      'reason',
      'details',
      'created_at',
      'status',
    ],
    notificationsTable: [
      'notif_id',
      'profile_id',
      'type',
      'title',
      'body',
      'payload',
      'created_at',
      'is_read',
    ],
    plansTable: [
      'plan_id',
      'name',
      'price_inr',
      'duration_months',
      'contacts_view_limit',
      'chat_enabled',
      'highlight',
      'horoscope_match',
      'features_json',
    ],
    subscriptionsTable: [
      'sub_id',
      'user_id',
      'plan_id',
      'started_at',
      'expires_at',
      'payment_ref',
      'status',
    ],
    otpCodesTable: [
      'mobile',
      'otp_hash',
      'expires_at',
      'attempts',
    ],
    successStoriesTable: [
      'story_id',
      'groom',
      'bride',
      'location',
      'story',
      'photo',
      'wedding_date',
      'is_demo',
    ],
    contactViewsTable: [
      'viewer_profile',
      'viewed_profile',
      'viewed_at',
    ],
    helpTicketsTable: [
      'ticket_id',
      'user_id',
      'subject',
      'message',
      'status',
      'created_at',
    ],
  };
}
