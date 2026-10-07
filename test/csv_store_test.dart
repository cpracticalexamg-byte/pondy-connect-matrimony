import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_schema.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late CsvStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pondy_test_db');
    store = CsvStore.instance;
    store.invalidateCache();
    await store.initialize(customDir: tempDir);
  });

  tearDown(() async {
    store.invalidateCache();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('CsvStore inserts, reads and queries data accurately', () async {
    final testUser = {
      'user_id': 'USR000001',
      'mobile': '+91 98400 12345',
      'email': 'anand.k@example.com',
      'password_hash': 'hash123',
      'salt': 'salt123',
      'profile_for': 'Myself',
      'created_at': DateTime.now().toIso8601String(),
      'last_login': DateTime.now().toIso8601String(),
      'status': 'active',
      'plan_id': 'free',
      'plan_expiry': '',
      'is_verified': 'true',
      'is_demo': 'false',
    };

    await store.insert(CsvSchema.usersTable, testUser);

    final all = await store.readAll(CsvSchema.usersTable);
    expect(all.length, 1);
    expect(all.first['user_id'], 'USR000001');
    expect(all.first['mobile'], '+91 98400 12345');

    final queried = await store.query(
      CsvSchema.usersTable,
      (row) => row['mobile'] == '+91 98400 12345',
    );
    expect(queried.length, 1);
    expect(queried.first['user_id'], 'USR000001');
  });

  test('CsvStore handles Unicode, Tamil text, commas and quotation marks safely', () async {
    final complexProfile = {
      'profile_id': 'PC000001',
      'user_id': 'USR000001',
      'name': 'முருகன், செந்தில்',
      'gender': 'Male',
      'dob': '1995-05-12',
      'age': '30',
      'height_cm': '175',
      'physical_status': 'Normal',
      'marital_status': 'never_married',
      'no_of_children': '0',
      'mother_tongue': 'tamil',
      'religion': 'hindu',
      'division': 'none',
      'caste': 'mudaliar',
      'subcaste': 'Thuluva "Vellalar"',
      'willing_other_caste': 'true',
      'star': 'ashwini',
      'rasi': 'mesha',
      'dosham': 'none',
      'gothram': 'Siva',
      'country': 'India',
      'state': 'Puducherry',
      'district': 'puducherry',
      'city': 'Puducherry',
      'citizenship': 'Indian',
      'education': 'be_btech',
      'education_detail': 'B.Tech, CSE',
      'employment_type': 'private',
      'occupation': 'software_engineer',
      'employer': 'Tech Corp, India',
      'income_currency': 'INR',
      'annual_income_range': '10_to_15_lakhs',
      'family_status': 'middle_class',
      'family_type': 'nuclear',
      'family_values': 'moderate',
      'father_occupation': 'Business',
      'mother_occupation': 'Teacher',
      'brothers': '1',
      'sisters': '0',
      'diet': 'vegetarian',
      'smoking': 'No',
      'drinking': 'No',
      'about_me': 'வணக்கம்! Looking for a life partner, with kind values and understanding.',
      'profile_photo_privacy': 'all',
      'completeness_pct': '85',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_demo': 'false',
    };

    await store.insert(CsvSchema.profilesTable, complexProfile);

    // Read back and verify exact Unicode and quote preservation
    final profiles = await store.readAll(CsvSchema.profilesTable);
    expect(profiles.length, 1);
    expect(profiles.first['name'], 'முருகன், செந்தில்');
    expect(profiles.first['subcaste'], 'Thuluva "Vellalar"');
    expect(profiles.first['employer'], 'Tech Corp, India');
    expect(profiles.first['about_me'], contains('வணக்கம்!'));
  });

  test('CsvStore handles concurrent writes without corruption via CsvLock', () async {
    const totalWrites = 25;
    final futures = <Future<void>>[];

    for (int i = 1; i <= totalWrites; i++) {
      futures.add(
        store.insert(CsvSchema.notificationsTable, {
          'notif_id': 'NOT$i',
          'profile_id': 'PC000001',
          'type': 'system',
          'title': 'Test Notification $i',
          'body': 'Concurrent write message body $i',
          'payload': '',
          'created_at': DateTime.now().toIso8601String(),
          'is_read': 'false',
        }),
      );
    }

    await Future.wait(futures);

    final notifications = await store.readAll(CsvSchema.notificationsTable);
    expect(notifications.length, totalWrites);
  });

  test('CsvStore generates sequential IDs with prefix correctly', () async {
    final id1 = await store.nextId(CsvSchema.profilesTable, 'profile_id', 'PC', 6);
    expect(id1, 'PC000001');

    await store.insert(CsvSchema.profilesTable, {
      'profile_id': id1,
      'user_id': 'USR001',
      'name': 'Test User',
      'gender': 'Male',
      'dob': '1998-01-01',
      'age': '28',
      'height_cm': '170',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    final id2 = await store.nextId(CsvSchema.profilesTable, 'profile_id', 'PC', 6);
    expect(id2, 'PC000002');
  });
}
