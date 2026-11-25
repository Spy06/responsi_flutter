import 'package:flutter/material.dart';

import '../../../models/weather_model.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final WeatherModel weather;

  const WeatherMetricsGrid({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final theme = Theme.of(context);

    final metrics = <_MetricItemData>[
      _MetricItemData(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF0284C7),
        label: 'Kelembapan Udara',
        value: '${current.relativeHumidity2m}%',
        caption: 'Kelembapan relatif saat ini',
      ),
      _MetricItemData(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF0D9488),
        label: 'Kecepatan Angin',
        value: '${current.windSpeed10m.toStringAsFixed(1)} km/j',
        caption: 'Ketinggian 10 meter',
      ),
      _MetricItemData(
        icon: Icons.umbrella_rounded,
        iconColor: const Color(0xFF2563EB),
        label: 'Peluang Hujan',
        value: '${weather.todayRainProbability}%',
        caption: 'Peluang maks hari ini',
      ),
      _MetricItemData(
        icon: Icons.grain_rounded,
        iconColor: const Color(0xFF4F46E5),
        label: 'Curah Hujan',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
        caption: 'Presipitasi terkini',
      ),
      _MetricItemData(
        icon: Icons.device_thermostat_rounded,
        iconColor: const Color(0xFFEA580C),
        label: 'Suhu Dirasakan',
        value: '${current.apparentTemperature.toStringAsFixed(1)}°C',
        caption: 'Apparent temperature',
      ),
      _MetricItemData(
        icon: Icons.public_rounded,
        iconColor: const Color(0xFF7C3AED),
        label: 'Zona Waktu',
        value: weather.timezoneAbbreviation.isNotEmpty
            ? weather.timezoneAbbreviation
            : weather.timezone,
        caption: weather.timezone,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Kondisi Cuaca',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 560 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 112,
              ),
              itemBuilder: (context, index) {
                return _MetricCard(data: metrics[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class _MetricItemData {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String caption;

  const _MetricItemData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.caption,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricItemData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: data.iconColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    data.icon,
                    size: 18,
                    color: data.iconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 19),
            ),
            Text(
              data.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}
