import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint &&
          runtimeType == other.runtimeType &&
          (latitude - other.latitude).abs() < 0.00001 &&
          (longitude - other.longitude).abs() < 0.00001;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}

class GeoUtils {
  static const double earthRadiusKm = 6371.0;

  // Well-known district and area centroids for Puducherry & Tamil Nadu
  static const Map<String, GeoPoint> districtCentroids = {
    'puducherry': GeoPoint(11.9416, 79.8083),
    'lawspet': GeoPoint(11.9610, 79.8160),
    'white_town': GeoPoint(11.9333, 79.8333),
    'muthialpet': GeoPoint(11.9500, 79.8300),
    'villianur': GeoPoint(11.9144, 79.7617),
    'ariyankuppam': GeoPoint(11.8900, 79.8050),
    'karaikal': GeoPoint(10.9254, 79.8380),
    'cuddalore': GeoPoint(11.7480, 79.7714),
    'villupuram': GeoPoint(11.9401, 79.4861),
    'chennai': GeoPoint(13.0827, 80.2707),
    'madurai': GeoPoint(9.9252, 78.1198),
    'coimbatore': GeoPoint(11.0168, 76.9558),
    'salem': GeoPoint(11.6643, 78.1460),
    'tirunelveli': GeoPoint(8.7139, 77.7567),
    'thoothukudi': GeoPoint(8.7642, 78.1348),
    'bengaluru': GeoPoint(12.9716, 77.5946),
    'singapore': GeoPoint(1.3521, 103.8198),
    'london': GeoPoint(51.5074, -0.1278),
  };

  /// Computes distance in kilometers between two points using the Haversine formula.
  static double haversineDistanceKm(GeoPoint p1, GeoPoint p2) {
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLon = _toRadians(p2.longitude - p1.longitude);

    final lat1 = _toRadians(p1.latitude);
    final lat2 = _toRadians(p2.latitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;

  /// Snaps raw GPS coordinates to a ~300-500m grid with stored deterministic jitter.
  /// Raw GPS coordinates are NEVER stored in the database.
  static GeoPoint snapToCoarseGrid(GeoPoint raw, {required String profileId}) {
    // 0.004 degrees latitude is approximately 440 meters
    const gridStep = 0.004;

    // Grid snap
    final snappedLat = (raw.latitude / gridStep).round() * gridStep;
    final snappedLng = (raw.longitude / gridStep).round() * gridStep;

    // Deterministic jitter based on profileId hash (± 0.001 deg ~ 100m)
    final bytes = md5.convert(utf8.encode(profileId)).bytes;
    final jitterLat = ((bytes[0] / 255.0) - 0.5) * 0.002;
    final jitterLng = ((bytes[1] / 255.0) - 0.5) * 0.002;

    final coarseLat = double.parse((snappedLat + jitterLat).toStringAsFixed(4));
    final coarseLng = double.parse((snappedLng + jitterLng).toStringAsFixed(4));

    return GeoPoint(coarseLat, coarseLng);
  }

  /// Formats the calculated distance string according to privacy and precision rules (§4):
  /// - If target's share_mode is 'hidden' -> returns null (do not display)
  /// - If below 0.3 km -> "< 0.5 km away" (prevents trilateration)
  /// - Under 10 km:
  ///   - if mode is 'approx' -> rounded to nearest km (e.g. "~3 km away")
  ///   - if mode is 'precise' -> rounded to 0.1 km (e.g. "3.4 km away")
  /// - Above 10 km -> rounded to nearest 1 km (e.g. "42 km away")
  static String? formatDistance(
    double? distanceKm, {
    String shareMode = 'precise',
    String? cityOrDistrict,
  }) {
    if (shareMode == 'hidden') return null;

    if (distanceKm == null) {
      if (cityOrDistrict != null && cityOrDistrict.isNotEmpty) {
        return 'in $cityOrDistrict';
      }
      return null;
    }

    if (distanceKm < 0.3) {
      return '< 0.5 km away';
    }

    if (shareMode == 'approx') {
      final approx = distanceKm.round();
      return approx == 0 ? '< 1 km away' : '~$approx km away';
    }

    if (distanceKm < 10.0) {
      return '${distanceKm.toStringAsFixed(1)} km away';
    }

    return '${distanceKm.round()} km away';
  }

  /// Generates a standard Base32 geohash string with specified precision (default 5 ~ 4.9km x 4.9km tile).
  static String encodeGeohash(double latitude, double longitude, {int precision = 5}) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var latMin = -90.0, latMax = 90.0;
    var lonMin = -180.0, lonMax = 180.0;

    final result = StringBuffer();
    var isEven = true;
    var bit = 0;
    var ch = 0;

    while (result.length < precision) {
      if (isEven) {
        final mid = (lonMin + lonMax) / 2;
        if (longitude > mid) {
          ch |= (1 << (4 - bit));
          lonMin = mid;
        } else {
          lonMax = mid;
        }
      } else {
        final mid = (latMin + latMax) / 2;
        if (latitude > mid) {
          ch |= (1 << (4 - bit));
          latMin = mid;
        } else {
          latMax = mid;
        }
      }

      isEven = !isEven;
      if (bit < 4) {
        bit++;
      } else {
        result.write(base32[ch]);
        bit = 0;
        ch = 0;
      }
    }

    return result.toString();
  }

  /// Gets centroid GeoPoint for a city/district name fallback.
  static GeoPoint getCentroidForLocation(String locationName) {
    final key = locationName.toLowerCase().trim().replaceAll(' ', '_');
    return districtCentroids[key] ?? districtCentroids['puducherry']!;
  }
}
