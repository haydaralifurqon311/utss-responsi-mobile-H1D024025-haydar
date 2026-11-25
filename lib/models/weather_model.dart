class WeatherModel {
  const WeatherModel({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentData = _requiredMap(json, 'current');
    final hourlyData = _requiredMap(json, 'hourly');
    final dailyData = _requiredMap(json, 'daily');

    final hourlyTimes = _requiredList(hourlyData, 'time');
    final hourlyTemperatures = _requiredList(hourlyData, 'temperature_2m');
    final hourlyCodes = _requiredList(hourlyData, 'weather_code');
    final hourlyPrecipitation = _requiredList(
      hourlyData,
      'precipitation_probability',
    );
    _checkLengths('hourly', [
      hourlyTimes,
      hourlyTemperatures,
      hourlyCodes,
      hourlyPrecipitation,
    ]);

    final dailyDates = _requiredList(dailyData, 'time');
    final dailyCodes = _requiredList(dailyData, 'weather_code');
    final dailyMaxTemps = _requiredList(dailyData, 'temperature_2m_max');
    final dailyMinTemps = _requiredList(dailyData, 'temperature_2m_min');
    final dailyPrecipitation = _requiredList(
      dailyData,
      'precipitation_probability_max',
    );
    final dailyUvIndices = _requiredList(dailyData, 'uv_index_max');
    final dailySunsets = _requiredList(dailyData, 'sunset');
    _checkLengths('daily', [
      dailyDates,
      dailyCodes,
      dailyMaxTemps,
      dailyMinTemps,
      dailyPrecipitation,
      dailyUvIndices,
      dailySunsets,
    ]);

    return WeatherModel(
      current: CurrentWeather(
        temperature2m: _requiredDouble(currentData, 'temperature_2m'),
        relativeHumidity: _requiredInt(currentData, 'relative_humidity_2m'),
        apparentTemperature: _requiredDouble(
          currentData,
          'apparent_temperature',
        ),
        precipitation: _requiredDouble(currentData, 'precipitation'),
        weatherCode: _requiredInt(currentData, 'weather_code'),
        windSpeed: _requiredDouble(currentData, 'wind_speed_10m'),
        isDay: _requiredInt(currentData, 'is_day') == 1,
        time: _requiredString(currentData, 'time'),
      ),
      hourly: List<HourlyWeather>.generate(
        hourlyTimes.length,
        (index) => HourlyWeather(
          time: _stringValue(hourlyTimes[index], 'hourly.time'),
          temperature: _doubleValue(
            hourlyTemperatures[index],
            'hourly.temperature_2m',
          ),
          weatherCode: _intValue(hourlyCodes[index], 'hourly.weather_code'),
          precipitationProbability: _intValue(
            hourlyPrecipitation[index],
            'hourly.precipitation_probability',
          ),
        ),
      ),
      daily: List<DailyWeather>.generate(
        dailyDates.length,
        (index) => DailyWeather(
          date: _stringValue(dailyDates[index], 'daily.time'),
          weatherCode: _intValue(dailyCodes[index], 'daily.weather_code'),
          tempMax: _doubleValue(
            dailyMaxTemps[index],
            'daily.temperature_2m_max',
          ),
          tempMin: _doubleValue(
            dailyMinTemps[index],
            'daily.temperature_2m_min',
          ),
          precipitationProbabilityMax: _intValue(
            dailyPrecipitation[index],
            'daily.precipitation_probability_max',
          ),
          uvIndexMax: _doubleValue(dailyUvIndices[index], 'daily.uv_index_max'),
          sunset: _stringValue(dailySunsets[index], 'daily.sunset'),
        ),
      ),
    );
  }
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
    required this.time,
  });

  final double temperature2m;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final bool isDay;
  final String time;
}

class HourlyWeather {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  final String time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
}

class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbabilityMax,
    required this.uvIndexMax,
    required this.sunset,
  });

  final String date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int precipitationProbabilityMax;
  final double uvIndexMax;
  final String sunset;
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('Data "$key" tidak valid.');
}

List<dynamic> _requiredList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List<dynamic>) {
    return value;
  }
  throw FormatException('Data "$key" tidak valid.');
}

void _checkLengths(String section, List<List<dynamic>> lists) {
  final expectedLength = lists.first.length;
  if (lists.any((list) => list.length != expectedLength)) {
    throw FormatException('Jumlah data pada bagian "$section" tidak sama.');
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  return _stringValue(json[key], key);
}

String _stringValue(Object? value, String key) {
  if (value is String) {
    return value;
  }
  throw FormatException('Nilai "$key" tidak valid.');
}

double _requiredDouble(Map<String, dynamic> json, String key) {
  return _doubleValue(json[key], key);
}

double _doubleValue(Object? value, String key) {
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('Nilai "$key" tidak valid.');
}

int _requiredInt(Map<String, dynamic> json, String key) {
  return _intValue(json[key], key);
}

int _intValue(Object? value, String key) {
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Nilai "$key" tidak valid.');
}
