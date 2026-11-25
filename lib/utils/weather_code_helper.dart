import 'package:flutter/material.dart';

class WeatherConditionInfo {
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;

  const WeatherConditionInfo({
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
  });
}

class WeatherCodeHelper {
  const WeatherCodeHelper._();

  static WeatherConditionInfo getInfo(int code) {
    switch (code) {
      case 0:
        return const WeatherConditionInfo(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          accentColor: Color(0xFFF59E0B),
          gradientColors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
        );
      case 1:
        return const WeatherConditionInfo(
          description: 'Cerah Berawan',
          icon: Icons.wb_sunny_outlined,
          accentColor: Color(0xFFFBBF24),
          gradientColors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
        );
      case 2:
        return const WeatherConditionInfo(
          description: 'Berawan Sebagian',
          icon: Icons.cloud_queue_rounded,
          accentColor: Color(0xFF38BDF8),
          gradientColors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        );
      case 3:
        return const WeatherConditionInfo(
          description: 'Mendung',
          icon: Icons.cloud_rounded,
          accentColor: Color(0xFF64748B),
          gradientColors: [Color(0xFF334155), Color(0xFF64748B)],
        );
      case 45:
      case 48:
        return const WeatherConditionInfo(
          description: 'Berkabut',
          icon: Icons.foggy,
          accentColor: Color(0xFF94A3B8),
          gradientColors: [Color(0xFF475569), Color(0xFF94A3B8)],
        );
      case 51:
        return const WeatherConditionInfo(
          description: 'Gerimis Ringan',
          icon: Icons.grain_rounded,
          accentColor: Color(0xFF0EA5E9),
          gradientColors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        );
      case 53:
        return const WeatherConditionInfo(
          description: 'Gerimis Sedang',
          icon: Icons.grain_rounded,
          accentColor: Color(0xFF0284C7),
          gradientColors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
        );
      case 55:
      case 56:
      case 57:
        return const WeatherConditionInfo(
          description: 'Gerimis Lebat',
          icon: Icons.grain_rounded,
          accentColor: Color(0xFF0369A1),
          gradientColors: [Color(0xFF1E293B), Color(0xFF1E40AF)],
        );
      case 61:
        return const WeatherConditionInfo(
          description: 'Hujan Ringan',
          icon: Icons.umbrella_rounded,
          accentColor: Color(0xFF2563EB),
          gradientColors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        );
      case 63:
        return const WeatherConditionInfo(
          description: 'Hujan Sedang',
          icon: Icons.umbrella_rounded,
          accentColor: Color(0xFF1D4ED8),
          gradientColors: [Color(0xFF172554), Color(0xFF1D4ED8)],
        );
      case 65:
      case 66:
      case 67:
        return const WeatherConditionInfo(
          description: 'Hujan Lebat',
          icon: Icons.water_drop_rounded,
          accentColor: Color(0xFF1E40AF),
          gradientColors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
        );
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return const WeatherConditionInfo(
          description: 'Bersalju',
          icon: Icons.ac_unit_rounded,
          accentColor: Color(0xFF06B6D4),
          gradientColors: [Color(0xFF0E7490), Color(0xFF22D3EE)],
        );
      case 80:
        return const WeatherConditionInfo(
          description: 'Hujan Lokal Ringan',
          icon: Icons.beach_access_rounded,
          accentColor: Color(0xFF3B82F6),
          gradientColors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        );
      case 81:
        return const WeatherConditionInfo(
          description: 'Hujan Lokal Sedang',
          icon: Icons.beach_access_rounded,
          accentColor: Color(0xFF2563EB),
          gradientColors: [Color(0xFF172554), Color(0xFF1D4ED8)],
        );
      case 82:
        return const WeatherConditionInfo(
          description: 'Hujan Lokal Deras',
          icon: Icons.water_drop_rounded,
          accentColor: Color(0xFF1D4ED8),
          gradientColors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
        );
      case 95:
      case 96:
      case 99:
        return const WeatherConditionInfo(
          description: 'Badai Petir',
          icon: Icons.thunderstorm_rounded,
          accentColor: Color(0xFF7C3AED),
          gradientColors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
        );
      default:
        return const WeatherConditionInfo(
          description: 'Berawan',
          icon: Icons.wb_cloudy_rounded,
          accentColor: Color(0xFF3B82F6),
          gradientColors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        );
    }
  }
}
