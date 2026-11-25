class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? countryCode;
  final String? admin1;
  final String? timezone;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.countryCode,
    this.admin1,
    this.timezone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  String get subtitle {
    final parts = <String>[];
    if (admin1 != null &&
        admin1!.trim().isNotEmpty &&
        admin1!.toLowerCase() != name.toLowerCase()) {
      parts.add(admin1!.trim());
    }
    if (country != null && country!.trim().isNotEmpty) {
      parts.add(country!.trim());
    }
    return parts.isEmpty
        ? '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}'
        : parts.join(', ');
  }

  String get fullDisplayName {
    if (country != null && country!.trim().isNotEmpty) {
      return '$name, $country';
    }
    return name;
  }

  bool isSameLocation(LocationModel other) {
    if (id != 0 && other.id != 0) {
      return id == other.id;
    }
    return name.toLowerCase() == other.name.toLowerCase() &&
        (latitude - other.latitude).abs() < 0.01 &&
        (longitude - other.longitude).abs() < 0.01;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel && isSameLocation(other);
  }

  @override
  int get hashCode =>
      id != 0 ? id.hashCode : Object.hash(name.toLowerCase(), latitude.round(), longitude.round());
}
