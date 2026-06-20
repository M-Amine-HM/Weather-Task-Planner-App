import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/weather_model.dart';
import 'services/Api.dart';

class WeatherWidget extends StatefulWidget {
  final bool isDarkMode;
  final Function(
    Weather? weather,
    String? city,
    List<Map<String, dynamic>>? forecast,
  )?
  onWeatherUpdate;

  const WeatherWidget({
    super.key,
    required this.isDarkMode,
    this.onWeatherUpdate,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final TextEditingController _searchController = TextEditingController();

  Weather? _currentWeather;
  List<Map<String, dynamic>>? _forecast; // stores full forecast list
  List<Map<String, dynamic>> _hourly = []; // today's hourly slots
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather("Sousse");
  }

  Future<void> _fetchWeather(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      Weather? weather = await Api.getCurrentWeather(city.trim());
      Map<String, dynamic>? forecastData = await Api.getWeatherForecast(
        city.trim(),
        days: 7,
      );

      if (weather != null) {
        List<Map<String, dynamic>>? forecast;
        if (forecastData != null && forecastData['forecast'] != null) {
          try {
            forecast = (forecastData['forecast'] as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();
          } catch (e) {
            print('Error parsing forecast: $e');
          }
        }

        // Parse hourly from weather response
        List<Map<String, dynamic>> hourly = [];
        if (weather != null) {
          try {
            final raw = (weather as dynamic).hourly;
            if (raw != null) {
              hourly = (raw as List)
                  .map((e) => e as Map<String, dynamic>)
                  .toList();
            }
          } catch (_) {}
        }

        setState(() {
          _currentWeather = weather;
          _forecast = forecast;
          _hourly = hourly;
          _isLoading = false;
        });

        widget.onWeatherUpdate?.call(weather, city.trim(), forecast);
      } else {
        setState(() {
          _errorMessage = 'City not found. Please try again.';
          _isLoading = false;
        });
        widget.onWeatherUpdate?.call(null, null, null);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather. Check connection.';
        _isLoading = false;
      });
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.wb_cloudy;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'fog':
      case 'mist':
        return Icons.cloud;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orange;
      case 'clouds':
        return Colors.blueGrey;
      case 'rain':
      case 'drizzle':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.deepPurple;
      case 'snow':
        return Colors.lightBlue;
      case 'fog':
      case 'mist':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  // ── Next 3 Days forecast strip ────────────────────────────────────────────
  Widget _buildNext3Days(bool isCompact) {
    if (_forecast == null || _forecast!.isEmpty) return const SizedBox.shrink();

    // Skip index 0 (today), take next 3
    final next3 = _forecast!.skip(1).take(3).toList();
    if (next3.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isCompact ? 12.h : 16.h),
        Row(
          children: [
            // Icon(
            //   Icons.calendar_today,
            //   size: isCompact ? 14.sp : 16.sp,
            //   color: widget.isDarkMode
            //       ? Colors.blue[300]
            //       : const Color(0xFF1E4A7B),
            // ),
            // SizedBox(width: 6.w),
            // Text(
            //   "Next 3 Days",
            //   style: TextStyle(
            //     fontSize: isCompact ? 13.sp : 15.sp,
            //     fontWeight: FontWeight.bold,
            //     color: widget.isDarkMode ? Colors.white : Colors.black87,
            //   ),
            // ),
          ],
        ),
        SizedBox(height: isCompact ? 8.h : 10.h),
        Row(
          children: next3.map((day) {
            final date = DateTime.tryParse(day['date'] ?? '');
            final dayLabel = date != null
                ? _getDayLabel(date)
                : (day['date'] ?? '');
            final condition = day['condition'] ?? 'Clear';
            final maxTemp = day['temperature_max']?.toStringAsFixed(0) ?? '--';
            final minTemp = day['temperature_min']?.toStringAsFixed(0) ?? '--';

            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(
                  vertical: isCompact ? 8.h : 12.h,
                  horizontal: isCompact ? 4.w : 6.w,
                ),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.grey[700] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.white12
                        : Colors.blue.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day name
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: isCompact ? 11.sp : 13.sp,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode
                            ? Colors.white70
                            : const Color(0xFF1E4A7B),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Weather icon
                    Icon(
                      _getWeatherIcon(condition),
                      size: isCompact ? 22.sp : 26.sp,
                      color: _getConditionColor(condition),
                    ),
                    SizedBox(height: 6.h),
                    // Condition label
                    Text(
                      condition,
                      style: TextStyle(
                        fontSize: isCompact ? 10.sp : 11.sp,
                        color: widget.isDarkMode
                            ? Colors.white54
                            : Colors.black45,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    // Max / Min temp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$maxTemp°',
                          style: TextStyle(
                            fontSize: isCompact ? 13.sp : 15.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        Text(
                          ' / ',
                          style: TextStyle(
                            fontSize: isCompact ? 11.sp : 12.sp,
                            color: widget.isDarkMode
                                ? Colors.white38
                                : Colors.black26,
                          ),
                        ),
                        Text(
                          '$minTemp°',
                          style: TextStyle(
                            fontSize: isCompact ? 11.sp : 13.sp,
                            color: widget.isDarkMode
                                ? Colors.white54
                                : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getDayLabel(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: widget.isDarkMode
            ? LinearGradient(
                colors: [Colors.grey[850]!, Colors.grey[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isCompact =
              constraints.maxWidth < 300 || constraints.maxHeight < 400;
          bool isVeryCompact =
              constraints.maxWidth < 250 || constraints.maxHeight < 350;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Icon(
                    Icons.cloud,
                    color: widget.isDarkMode
                        ? Colors.blue[300]
                        : const Color(0xFF1E4A7B),
                    size: isVeryCompact ? 20.sp : (isCompact ? 24.sp : 28.sp),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Weather Forecast",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isVeryCompact
                            ? 16.sp
                            : (isCompact ? 18.sp : 20.sp),
                        color: widget.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isVeryCompact ? 10.h : (isCompact ? 12.h : 15.h),
              ),

              // Search Bar
              TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: isVeryCompact ? 12.sp : (isCompact ? 13.sp : 14.sp),
                ),
                onSubmitted: (value) => _fetchWeather(value),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: isVeryCompact ? 18.sp : (isCompact ? 20.sp : 22.sp),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: const Color(0xFF1E4A7B),
                      size: isVeryCompact ? 18.sp : (isCompact ? 20.sp : 22.sp),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _fetchWeather(_searchController.text),
                  ),
                  hintText: isVeryCompact ? "Search..." : "Search city...",
                  hintStyle: TextStyle(
                    fontSize: isVeryCompact
                        ? 12.sp
                        : (isCompact ? 13.sp : 14.sp),
                    color: Colors.grey[500],
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isVeryCompact ? 8.h : (isCompact ? 10.h : 12.h),
                    horizontal: isVeryCompact ? 8.w : (isCompact ? 10.w : 12.w),
                  ),
                  isDense: isVeryCompact,
                ),
              ),
              SizedBox(
                height: isVeryCompact ? 10.h : (isCompact ? 12.h : 15.h),
              ),

              // Current Weather + 3-day forecast
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    isVeryCompact ? 12.w : (isCompact ? 16.w : 20.w),
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: widget.isDarkMode
                                ? Colors.blue[300]
                                : const Color(0xFF1E4A7B),
                          ),
                        )
                      : _errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.sp,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _currentWeather == null
                      ? Center(
                          child: Text(
                            'Search for a city',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // City Name
                              Text(
                                _currentWeather!.city,
                                style: TextStyle(
                                  fontSize: isVeryCompact
                                      ? 18.sp
                                      : (isCompact ? 22.sp : 26.sp),
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: isVeryCompact
                                    ? 8.h
                                    : (isCompact ? 12.h : 15.h),
                              ),

                              // Weather Icon and Temperature
                              isVeryCompact
                                  ? Column(
                                      children: [
                                        Icon(
                                          _getWeatherIcon(
                                            _currentWeather!.condition,
                                          ),
                                          size: 50.sp,
                                          color: _getConditionColor(
                                            _currentWeather!.condition,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
                                          style: TextStyle(
                                            fontSize: 32.sp,
                                            fontWeight: FontWeight.bold,
                                            color: widget.isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getWeatherIcon(
                                            _currentWeather!.condition,
                                          ),
                                          size: isCompact ? 60.sp : 70.sp,
                                          color: _getConditionColor(
                                            _currentWeather!.condition,
                                          ),
                                        ),
                                        SizedBox(
                                          width: isCompact ? 12.w : 16.w,
                                        ),
                                        Text(
                                          '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
                                          style: TextStyle(
                                            fontSize: isCompact ? 40.sp : 48.sp,
                                            fontWeight: FontWeight.bold,
                                            color: widget.isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                              SizedBox(
                                height: isVeryCompact
                                    ? 6.h
                                    : (isCompact ? 8.h : 10.h),
                              ),

                              // Condition text
                              Text(
                                '${_currentWeather!.condition} - ${_currentWeather!.description}',
                                style: TextStyle(
                                  fontSize: isVeryCompact
                                      ? 14.sp
                                      : (isCompact ? 16.sp : 18.sp),
                                  color: widget.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: isVeryCompact
                                    ? 12.h
                                    : (isCompact ? 16.h : 20.h),
                              ),

                              // Weather details row
                              isVeryCompact
                                  ? Column(
                                      children: [
                                        _buildCompactWeatherDetail(
                                          Icons.water_drop,
                                          "Humidity",
                                          '${_currentWeather!.humidity}%',
                                          isVeryCompact,
                                        ),
                                        SizedBox(height: 8.h),
                                        _buildCompactWeatherDetail(
                                          Icons.air,
                                          "Wind",
                                          '${_currentWeather!.windSpeed.toStringAsFixed(1)} km/h',
                                          isVeryCompact,
                                        ),
                                        SizedBox(height: 8.h),
                                        _buildCompactWeatherDetail(
                                          Icons.thermostat,
                                          "Feels Like",
                                          '${_currentWeather!.feelsLike.toStringAsFixed(1)}°C',
                                          isVeryCompact,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                          child: _buildWeatherDetail(
                                            Icons.water_drop,
                                            "Humidity",
                                            '${_currentWeather!.humidity}%',
                                            isCompact,
                                          ),
                                        ),
                                        Container(
                                          height: isCompact ? 40.h : 50.h,
                                          width: 1,
                                          color: widget.isDarkMode
                                              ? Colors.white24
                                              : Colors.black12,
                                        ),
                                        Flexible(
                                          child: _buildWeatherDetail(
                                            Icons.air,
                                            "Wind",
                                            '${_currentWeather!.windSpeed.toStringAsFixed(1)} km/h',
                                            isCompact,
                                          ),
                                        ),
                                        Container(
                                          height: isCompact ? 40.h : 50.h,
                                          width: 1,
                                          color: widget.isDarkMode
                                              ? Colors.white24
                                              : Colors.black12,
                                        ),
                                        Flexible(
                                          child: _buildWeatherDetail(
                                            Icons.thermostat,
                                            "Feels Like",
                                            '${_currentWeather!.feelsLike.toStringAsFixed(1)}°C',
                                            isCompact,
                                          ),
                                        ),
                                      ],
                                    ),

                              // ── Next 3 Days ──────────────────────
                              _buildNext3Days(isCompact),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeatherDetail(
    IconData icon,
    String label,
    String value,
    bool isCompact,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: widget.isDarkMode ? Colors.blue[300] : const Color(0xFF1E4A7B),
          size: isCompact ? 22.sp : 26.sp,
        ),
        SizedBox(height: isCompact ? 4.h : 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 11.sp : 13.sp,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 14.sp : 16.sp,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompactWeatherDetail(
    IconData icon,
    String label,
    String value,
    bool isVeryCompact,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: widget.isDarkMode ? Colors.blue[300] : const Color(0xFF1E4A7B),
          size: 18.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 12.sp,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
