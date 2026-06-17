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
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather("New York");
  }

  Future<void> _fetchWeather(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch both current weather and forecast
      Weather? weather = await Api.getCurrentWeather(city.trim());
      Map<String, dynamic>? forecastData = await Api.getWeatherForecast(
        city.trim(),
        days: 7,
      );

      if (weather != null) {
        setState(() {
          _currentWeather = weather;
          _isLoading = false;
        });
        // Notify parent dashboard about weather and forecast update
        List<Map<String, dynamic>>? forecast;
        if (forecastData != null && forecastData['forecast'] != null) {
          try {
            forecast = (forecastData['forecast'] as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();
            print('Forecast loaded: ${forecast.length} days');
          } catch (e) {
            print('Error parsing forecast: $e');
          }
        }
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
          // Determine compact mode based on available space
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
                    onPressed: () {
                      _fetchWeather(_searchController.text);
                    },
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

              // Current Weather Display
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
                                          color: widget.isDarkMode
                                              ? Colors.blue[300]
                                              : Colors.orange,
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
                                          color: widget.isDarkMode
                                              ? Colors.blue[300]
                                              : Colors.orange,
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

                              // Weather Condition
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

                              // Weather Details
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
