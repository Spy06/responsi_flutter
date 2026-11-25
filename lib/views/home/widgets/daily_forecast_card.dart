import 'package:flutter/material.dart';

import '../../../models/weather_model.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/weather_code_helper.dart';

class DailyForecastSection extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const DailyForecastSection({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    double overallMin = forecasts.first.temperature2mMin;
    double overallMax = forecasts.first.temperature2mMax;
    for (final day in forecasts) {
      if (day.temperature2mMin < overallMin) overallMin = day.temperature2mMin;
      if (day.temperature2mMax > overallMax) overallMax = day.temperature2mMax;
    }
    final tempSpan = (overallMax - overallMin).clamp(1.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prakiraan ${forecasts.length} Hari ke Depan',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: forecasts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            itemBuilder: (context, index) {
              final day = forecasts[index];
              final info = WeatherCodeHelper.getInfo(day.weatherCode);
              final startFraction =
                  ((day.temperature2mMin - overallMin) / tempSpan)
                      .clamp(0.0, 1.0);
              final endFraction =
                  ((day.temperature2mMax - overallMin) / tempSpan)
                      .clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.formatForecastDay(
                              day.date,
                              index: index,
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  index == 0 ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateFormatter.formatShortDate(day.date)} • ${info.description}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            info.icon,
                            size: 18,
                            color: info.accentColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${day.precipitationProbabilityMax}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 118,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${day.temperature2mMin.round()}°',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, barConstraints) {
                                final totalW = barConstraints.maxWidth;
                                final left = totalW * startFraction;
                                final width =
                                    (totalW * (endFraction - startFraction))
                                        .clamp(8.0, totalW);
                                return Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: left.clamp(0.0, totalW - width),
                                        width: width,
                                        top: 0,
                                        bottom: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF38BDF8),
                                                Color(0xFFF59E0B),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(99),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${day.temperature2mMax.round()}°',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
