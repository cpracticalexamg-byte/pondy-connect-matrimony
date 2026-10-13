import 'package:flutter/foundation.dart';
import '../../data/csv/csv_schema.dart';
import '../../data/csv/csv_store.dart';
import 'geo_utils.dart';

class ProfileLocationRecord {
  final String profileId;
  final double latCoarse;
  final double lngCoarse;
  final String geohash5;
  final String shareMode; // 'precise', 'approx', 'hidden'
  final String source; // 'gps', 'manual', 'mock'
  final String updatedAt;

  const ProfileLocationRecord({
    required this.profileId,
    required this.latCoarse,
    required this.lngCoarse,
    required this.geohash5,
    this.shareMode = 'precise',
    this.source = 'manual',
    required this.updatedAt,
  });

  GeoPoint get point => GeoPoint(latCoarse, lngCoarse);

  Map<String, String> toMap() => {
        'profile_id': profileId,
        'lat_coarse': latCoarse.toString(),
        'lng_coarse': lngCoarse.toString(),
        'geohash5': geohash5,
        'share_mode': shareMode,
        'source': source,
        'updated_at': updatedAt,
      };

  factory ProfileLocationRecord.fromMap(Map<String, String> map) => ProfileLocationRecord(
        profileId: map['profile_id'] ?? '',
        latCoarse: double.tryParse(map['lat_coarse'] ?? '0.0') ?? 0.0,
        lngCoarse: double.tryParse(map['lng_coarse'] ?? '0.0') ?? 0.0,
        geohash5: map['geohash5'] ?? '',
        shareMode: map['share_mode'] ?? 'precise',
        source: map['source'] ?? 'manual',
        updatedAt: map['updated_at'] ?? '',
      );
}

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  // In-memory viewer current location (never persisted as raw coordinates)
  GeoPoint? _viewerLocation;

  // In-memory spatial index: geohash5 -> List of ProfileLocationRecord
  final Map<String, List<ProfileLocationRecord>> _spatialIndex = {};
  final Map<String, ProfileLocationRecord> _locationsByProfileId = {};

  bool _isInitialized = false;

  GeoPoint get viewerLocation => _viewerLocation ?? GeoUtils.districtCentroids['white_town']!;

  bool get hasViewerLocation => _viewerLocation != null;

  void setViewerLocation(GeoPoint point) {
    _viewerLocation = point;
  }

  /// Sets mock location for debug/demo testing
  void setMockLocation(String locationKey) {
    final point = GeoUtils.districtCentroids[locationKey.toLowerCase()] ??
        GeoUtils.districtCentroids['white_town']!;
    _viewerLocation = point;
  }

  /// Initializes the in-memory spatial index from profile_locations table
  Future<void> initSpatialIndex() async {
    try {
      final rows = await CsvStore.instance.readAll(CsvSchema.profileLocationsTable);
      _spatialIndex.clear();
      _locationsByProfileId.clear();

      for (final r in rows) {
        final rec = ProfileLocationRecord.fromMap(r);
        if (rec.profileId.isEmpty) continue;
        _locationsByProfileId[rec.profileId] = rec;

        _spatialIndex.putIfAbsent(rec.geohash5, () => []).add(rec);
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('[LocationService] init error: $e');
    }
  }

  /// Saves a profile location, ensuring RAW GPS IS NEVER SAVED.
  /// Snaps to coarse ~400m grid with deterministic jitter.
  Future<void> saveProfileLocation({
    required String profileId,
    required GeoPoint rawPoint,
    String shareMode = 'precise',
    String source = 'manual',
  }) async {
    final coarsePoint = GeoUtils.snapToCoarseGrid(rawPoint, profileId: profileId);
    final geohash5 = GeoUtils.encodeGeohash(coarsePoint.latitude, coarsePoint.longitude, precision: 5);

    final record = ProfileLocationRecord(
      profileId: profileId,
      latCoarse: coarsePoint.latitude,
      lngCoarse: coarsePoint.longitude,
      geohash5: geohash5,
      shareMode: shareMode,
      source: source,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    _locationsByProfileId[profileId] = record;
    _spatialIndex.putIfAbsent(geohash5, () => []).add(record);

    final store = CsvStore.instance;
    final existing = await store.query(
      CsvSchema.profileLocationsTable,
      (r) => r['profile_id'] == profileId,
    );

    if (existing.isEmpty) {
      await store.insert(CsvSchema.profileLocationsTable, record.toMap());
    } else {
      await store.update(
        CsvSchema.profileLocationsTable,
        record.toMap(),
        (r) => r['profile_id'] == profileId,
      );
    }
  }

  /// Calculates distance in km from current viewer to candidate profile.
  /// Uses target's stored coarse point and viewer's in-memory point.
  double? getDistanceToCandidate(String targetProfileId, {String? targetDistrict}) {
    final targetRecord = _locationsByProfileId[targetProfileId];
    final viewerPoint = viewerLocation;

    if (targetRecord != null) {
      if (targetRecord.shareMode == 'hidden') return null;
      return GeoUtils.haversineDistanceKm(viewerPoint, targetRecord.point);
    }

    // Fallback: estimate from target's district centroid if location record not yet seeded
    if (targetDistrict != null && targetDistrict.isNotEmpty) {
      final districtPoint = GeoUtils.getCentroidForLocation(targetDistrict);
      return GeoUtils.haversineDistanceKm(viewerPoint, districtPoint);
    }

    return null;
  }

  /// Formatted distance string for display on cards and profile detail.
  String? getFormattedDistance(String targetProfileId, {String? targetDistrict, String? targetCity}) {
    final targetRecord = _locationsByProfileId[targetProfileId];
    final shareMode = targetRecord?.shareMode ?? 'precise';

    if (shareMode == 'hidden') return null;

    final distanceKm = getDistanceToCandidate(targetProfileId, targetDistrict: targetDistrict);
    return GeoUtils.formatDistance(
      distanceKm,
      shareMode: shareMode,
      cityOrDistrict: targetCity ?? targetDistrict,
    );
  }

  /// Get nearby candidate profile IDs within radiusKm
  List<String> getCandidateIdsWithinRadius(double radiusKm) {
    final viewer = viewerLocation;
    final List<String> matchingProfileIds = [];

    for (final entry in _locationsByProfileId.entries) {
      if (entry.value.shareMode == 'hidden') continue;
      final dist = GeoUtils.haversineDistanceKm(viewer, entry.value.point);
      if (dist <= radiusKm) {
        matchingProfileIds.add(entry.key);
      }
    }

    return matchingProfileIds;
  }

  ProfileLocationRecord? getLocationRecord(String profileId) => _locationsByProfileId[profileId];

  bool get isInitialized => _isInitialized;
}
