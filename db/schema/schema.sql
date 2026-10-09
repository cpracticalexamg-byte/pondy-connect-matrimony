-- =====================================================================
-- Pondy Connect Matrimony V2 — Azure SQL Database DDL
-- Azure SQL / SQL Server (Transact-SQL) Compatible
-- =====================================================================

-- Schema Metadata
CREATE TABLE schema_meta (
    [key] NVARCHAR(64) NOT NULL PRIMARY KEY,
    [value] NVARCHAR(MAX) NOT NULL,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);

-- Users Table
CREATE TABLE users (
    [user_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [mobile] NVARCHAR(20) NOT NULL UNIQUE,
    [email] NVARCHAR(128) NULL,
    [password_hash] NVARCHAR(256) NOT NULL,
    [salt] NVARCHAR(64) NOT NULL,
    [status] NVARCHAR(20) NOT NULL DEFAULT 'active',
    [is_verified] BIT NOT NULL DEFAULT 0,
    [is_sample] BIT NOT NULL DEFAULT 0,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);
CREATE INDEX idx_users_status ON users([status]);
CREATE INDEX idx_users_mobile ON users([mobile]);

-- Profiles Table
CREATE TABLE profiles (
    [profile_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [user_id] NVARCHAR(36) NOT NULL UNIQUE FOREIGN KEY REFERENCES users([user_id]),
    [matrimony_id] NVARCHAR(16) NOT NULL UNIQUE,
    [name] NVARCHAR(100) NOT NULL,
    [gender] NVARCHAR(10) NOT NULL,
    [dob] DATE NOT NULL,
    [age] INT NOT NULL,
    [height_cm] INT NOT NULL,
    [weight_kg] INT NULL,
    [body_type_id] INT NULL,
    [complexion_id] INT NULL,
    [blood_group_id] INT NULL,
    [physical_status_id] INT NOT NULL DEFAULT 1,
    [disability_type_id] INT NULL,
    [marital_status_id] INT NOT NULL,
    [no_of_children] INT NOT NULL DEFAULT 0,
    [children_living_with_me] BIT NOT NULL DEFAULT 0,
    [mother_tongue_id] INT NOT NULL,
    [religion_id] INT NOT NULL,
    [division_id] INT NULL,
    [caste_id] INT NULL,
    [sub_caste_id] INT NULL,
    [gothram_id] INT NULL,
    [willing_other_caste] BIT NOT NULL DEFAULT 0,
    [about_me] NVARCHAR(1000) NULL,
    [profile_photo_privacy] NVARCHAR(20) NOT NULL DEFAULT 'all',
    [profile_source] NVARCHAR(20) NOT NULL DEFAULT 'organic',
    [is_sample] BIT NOT NULL DEFAULT 0,
    [completeness_pct] INT NOT NULL DEFAULT 50,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);
CREATE INDEX idx_profiles_matrimony_id ON profiles([matrimony_id]);
CREATE INDEX idx_profiles_gender_age ON profiles([gender], [age]);
CREATE INDEX idx_profiles_religion_caste ON profiles([religion_id], [caste_id]);

-- Profile Horoscopes
CREATE TABLE profile_horoscopes (
    [horoscope_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL UNIQUE FOREIGN KEY REFERENCES profiles([profile_id]),
    [nakshatra_id] INT NULL,
    [padam] INT NULL,
    [rasi_id] INT NULL,
    [lagnam_id] INT NULL,
    [dosham_id] INT NULL,
    [dasa_id] INT NULL,
    [dasa_balance_years] INT NULL,
    [dasa_balance_months] INT NULL,
    [dasa_balance_days] INT NULL,
    [time_of_birth] NVARCHAR(16) NULL,
    [place_of_birth] NVARCHAR(100) NULL,
    [chart_raasi_json] NVARCHAR(MAX) NULL,
    [chart_amsam_json] NVARCHAR(MAX) NULL,
    [horoscope_match_required] BIT NOT NULL DEFAULT 1,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);

-- Profile Location
CREATE TABLE profile_location (
    [location_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL UNIQUE FOREIGN KEY REFERENCES profiles([profile_id]),
    [country_id] INT NOT NULL,
    [state_id] INT NOT NULL,
    [district_id] INT NOT NULL,
    [city_id] INT NULL,
    [citizenship_id] INT NOT NULL DEFAULT 1,
    [residency_status_id] INT NULL,
    [native_district_id] INT NULL,
    [willing_to_relocate] BIT NOT NULL DEFAULT 1,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);

-- Profile Education & Career
CREATE TABLE profile_education_career (
    [edu_career_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL UNIQUE FOREIGN KEY REFERENCES profiles([profile_id]),
    [education_level_id] INT NOT NULL,
    [education_degree_id] INT NULL,
    [degree_detail] NVARCHAR(150) NULL,
    [institution] NVARCHAR(150) NULL,
    [employment_type_id] INT NOT NULL,
    [occupation_category_id] INT NULL,
    [occupation_id] INT NOT NULL,
    [employer] NVARCHAR(150) NULL,
    [job_location] NVARCHAR(100) NULL,
    [currency_id] INT NOT NULL DEFAULT 1,
    [annual_income_range_id] INT NOT NULL,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);

-- Profile Family
CREATE TABLE profile_family (
    [family_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL UNIQUE FOREIGN KEY REFERENCES profiles([profile_id]),
    [family_status_id] INT NOT NULL,
    [family_type_id] INT NOT NULL,
    [family_values_id] INT NOT NULL,
    [father_occupation_id] INT NULL,
    [mother_occupation_id] INT NULL,
    [brothers_count] INT NOT NULL DEFAULT 0,
    [brothers_married] INT NOT NULL DEFAULT 0,
    [sisters_count] INT NOT NULL DEFAULT 0,
    [sisters_married] INT NOT NULL DEFAULT 0,
    [native_place] NVARCHAR(100) NULL,
    [parents_status] NVARCHAR(30) NULL,
    [ancestral_origin] NVARCHAR(100) NULL,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);

-- Profile Lifestyle
CREATE TABLE profile_lifestyle (
    [lifestyle_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL UNIQUE FOREIGN KEY REFERENCES profiles([profile_id]),
    [diet_id] INT NOT NULL,
    [smoking_id] INT NOT NULL DEFAULT 1,
    [drinking_id] INT NOT NULL DEFAULT 1,
    [interests_notes] NVARCHAR(500) NULL,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);

-- Photos
CREATE TABLE photos (
    [photo_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [blob_path] NVARCHAR(256) NOT NULL,
    [is_primary] BIT NOT NULL DEFAULT 0,
    [privacy] NVARCHAR(20) NOT NULL DEFAULT 'all',
    [sort_order] INT NOT NULL DEFAULT 1,
    [is_sample] BIT NOT NULL DEFAULT 0,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);
CREATE INDEX idx_photos_profile_id ON photos([profile_id]);

-- Partner Preferences
CREATE TABLE partner_preferences (
    [pref_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL UNIQUE FOREIGN KEY REFERENCES profiles([profile_id]),
    [age_min] INT NOT NULL,
    [age_max] INT NOT NULL,
    [height_min_cm] INT NOT NULL,
    [height_max_cm] INT NOT NULL,
    [income_min_id] INT NULL,
    [diet_id] INT NULL,
    [smoking_id] INT NULL,
    [drinking_id] INT NULL,
    [star_match_required] BIT NOT NULL DEFAULT 0,
    [dosham_pref_id] INT NULL,
    [photo_only] BIT NOT NULL DEFAULT 0,
    [verified_only] BIT NOT NULL DEFAULT 0,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);

-- Partner Preference Multi-Values (Relational)
CREATE TABLE partner_preference_values (
    [id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [pref_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES partner_preferences([pref_id]),
    [field_name] NVARCHAR(32) NOT NULL,
    [master_id] INT NOT NULL,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    CONSTRAINT uq_pref_field_master UNIQUE ([pref_id], [field_name], [master_id])
);

-- Interests
CREATE TABLE interests (
    [interest_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [from_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [to_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [status] NVARCHAR(20) NOT NULL DEFAULT 'sent',
    [message] NVARCHAR(250) NULL,
    [sent_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [responded_at] DATETIMEOFFSET NULL,
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1,
    CONSTRAINT uq_interest_pair UNIQUE ([from_profile_id], [to_profile_id])
);

-- Conversations & Messages
CREATE TABLE conversations (
    [conversation_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_a] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [profile_b] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [last_message_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1,
    CONSTRAINT uq_conversation_pair UNIQUE ([profile_a], [profile_b])
);

CREATE TABLE messages (
    [message_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [conversation_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES conversations([conversation_id]),
    [from_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [to_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [text] NVARCHAR(2000) NOT NULL,
    [msg_type] NVARCHAR(20) NOT NULL DEFAULT 'text',
    [sent_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [delivered_at] DATETIMEOFFSET NULL,
    [read_at] DATETIMEOFFSET NULL,
    [deleted_at] DATETIMEOFFSET NULL,
    [row_version] INT NOT NULL DEFAULT 1
);
CREATE INDEX idx_messages_conversation ON messages([conversation_id], [sent_at]);

-- Shortlists, Blocks, Reports, Views
CREATE TABLE shortlists (
    [id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [target_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    CONSTRAINT uq_shortlist_pair UNIQUE ([profile_id], [target_profile_id])
);

CREATE TABLE blocks (
    [id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [blocker_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [blocked_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    CONSTRAINT uq_block_pair UNIQUE ([blocker_profile_id], [blocked_profile_id])
);

CREATE TABLE reports (
    [report_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [reporter_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [reported_profile_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES profiles([profile_id]),
    [reason_id] INT NOT NULL,
    [details] NVARCHAR(1000) NULL,
    [status] NVARCHAR(20) NOT NULL DEFAULT 'pending',
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [resolved_at] DATETIMEOFFSET NULL
);

-- Plans & Subscriptions
CREATE TABLE plans (
    [plan_id] INT NOT NULL PRIMARY KEY,
    [code] NVARCHAR(32) NOT NULL UNIQUE,
    [name] NVARCHAR(64) NOT NULL,
    [price_inr] INT NOT NULL,
    [duration_months] INT NOT NULL,
    [contacts_view_limit] INT NOT NULL,
    [chat_enabled] BIT NOT NULL DEFAULT 0,
    [highlight] BIT NOT NULL DEFAULT 0,
    [horoscope_match] BIT NOT NULL DEFAULT 1,
    [features_json] NVARCHAR(MAX) NOT NULL,
    [sort_order] INT NOT NULL DEFAULT 1,
    [is_active] BIT NOT NULL DEFAULT 1
);

CREATE TABLE subscriptions (
    [subscription_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [user_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES users([user_id]),
    [plan_id] INT NOT NULL FOREIGN KEY REFERENCES plans([plan_id]),
    [started_at] DATETIMEOFFSET NOT NULL,
    [expires_at] DATETIMEOFFSET NOT NULL,
    [payment_ref] NVARCHAR(64) NULL,
    [status] NVARCHAR(20) NOT NULL DEFAULT 'active',
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    [updated_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);

-- Consents (DPDP Act 2023)
CREATE TABLE consents (
    [consent_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [user_id] NVARCHAR(36) NOT NULL FOREIGN KEY REFERENCES users([user_id]),
    [terms_version] NVARCHAR(16) NOT NULL,
    [privacy_version] NVARCHAR(16) NOT NULL,
    [sensitive_data_consent] BIT NOT NULL DEFAULT 1,
    [photo_visibility_consent] BIT NOT NULL DEFAULT 1,
    [accepted_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);

-- Audit Log
CREATE TABLE audit_log (
    [log_id] NVARCHAR(36) NOT NULL PRIMARY KEY,
    [actor_id] NVARCHAR(36) NOT NULL,
    [action] NVARCHAR(64) NOT NULL,
    [entity] NVARCHAR(64) NOT NULL,
    [entity_id] NVARCHAR(64) NOT NULL,
    [details] NVARCHAR(MAX) NULL,
    [created_at] DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
