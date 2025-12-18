import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weatherwebapp/agendaPage.dart';
import 'package:weatherwebapp/chatbotwidget.dart';
import 'package:weatherwebapp/weatherPage.dart';
import 'models/plan_model.dart';
import 'models/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/Api.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isDarkMode = false;
  List<Plan> _plans = [];
  Weather? _currentWeather;
  String? _currentCity;
  List<Map<String, dynamic>>? _weatherForecast;
  bool _isLoadingLocation = false;

  // Helper method to get responsive text size
  double _getResponsiveTextSize(double mobileSize, double desktopSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return mobileSize;
    } else if (screenWidth < 1200) {
      return (mobileSize + desktopSize) / 2; // Average for tablet
    } else {
      return desktopSize;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      if (kIsWeb) {
        // For web, use browser's geolocation API through geolocator
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showMessage(
            'Location services are disabled. Please enable location in your browser.',
          );
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _showMessage(
              'Location permission denied. Please allow location access.',
            );
            setState(() {
              _isLoadingLocation = false;
            });
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          _showMessage('Location permissions are permanently denied.');
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      // Use reverse geocoding to get city name (simplified - you'll need geocoding API)
      // For now, fetch weather by coordinates and let backend handle city name
      await _fetchWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: \$e');
      _showMessage('Failed to get location: \${e.toString()}');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fetchWeatherByCoordinates(double lat, double lon) async {
    String cityName =
        'My Location (\${lat.toStringAsFixed(2)}°, \${lon.toStringAsFixed(2)}°)';

    try {
      // Fetch both current weather and forecast by coordinates
      Weather? weather = await Api.getWeatherByCoordinates(lat, lon);
      Map<String, dynamic>? forecastData = await Api.getForecastByCoordinates(
        lat,
        lon,
        days: 7,
      );

      if (weather != null) {
        setState(() {
          _currentWeather = weather;
          _currentCity = cityName;

          // Parse forecast data
          if (forecastData != null && forecastData['forecast'] != null) {
            try {
              _weatherForecast = (forecastData['forecast'] as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
            } catch (e) {
              print('Error parsing forecast: \$e');
              _weatherForecast = null;
            }
          }
        });

        _showMessage('Weather loaded for your location!');
      } else {
        _showMessage(
          'Could not fetch weather for your location. Make sure backend endpoint is available.',
        );
      }
    } catch (e) {
      print('Error fetching weather by coordinates: \$e');
      _showMessage('Failed to fetch weather: \${e.toString()}');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 4),
          backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.blue[900],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _isDarkMode
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFe3f2fd),
                    Color(0xFFbbdefb),
                    Color(0xFF90caf9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: MediaQuery.of(context).size.width < 600 ? 15.w : 40.w,
            ),
            child: Column(
              children: [
                // Header with App Title, Dark Mode Toggle and Current Location
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isSmallScreen = constraints.maxWidth < 600;

                    if (isSmallScreen) {
                      // Stack layout for small screens
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and dark mode in first row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "WeatherPlanner",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF1E4A7B),
                                      ),
                                    ),
                                    Text(
                                      "Plan Smarter",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Dark Mode Toggle - compact
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isDarkMode
                                          ? Icons.nightlight_round
                                          : Icons.wb_sunny,
                                      color: _isDarkMode
                                          ? Colors.blue[300]
                                          : Colors.orange,
                                      size: 22.sp,
                                    ),
                                    Switch(
                                      value: _isDarkMode,
                                      activeColor: const Color(0xFF1E4A7B),
                                      inactiveThumbColor: Colors.orange,
                                      activeTrackColor: Colors.blue[200],
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (value) {
                                        setState(() {
                                          _isDarkMode = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          // Location button in second row - full width
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingLocation
                                  ? null
                                  : _getCurrentLocation,
                              icon: _isLoadingLocation
                                  ? SizedBox(
                                      width: 16.sp,
                                      height: 16.sp,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.my_location,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                              label: Text(
                                _isLoadingLocation
                                    ? "Getting..."
                                    : "Current Location",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E4A7B),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Original layout for larger screens
                    return Row(
                      children: [
                        // App Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "WeatherPlanner",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1E4A7B),
                              ),
                            ),
                            Text(
                              "Plan Smarter with Weather Insights",
                              style: TextStyle(
                                fontSize: 14,
                                color: _isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Dark Mode Toggle
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? Colors.grey[800]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                color: _isDarkMode
                                    ? Colors.grey
                                    : Colors.orange,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Switch(
                                value: _isDarkMode,
                                activeColor: const Color(0xFF1E4A7B),
                                inactiveThumbColor: Colors.orange,
                                activeTrackColor: Colors.blue[200],
                                onChanged: (value) {
                                  setState(() {
                                    _isDarkMode = value;
                                  });
                                },
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.nightlight_round,
                                color: _isDarkMode
                                    ? Colors.blue[300]
                                    : Colors.grey,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.w),

                        // Current Location Button
                        ElevatedButton.icon(
                          onPressed: _isLoadingLocation
                              ? null
                              : _getCurrentLocation,
                          icon: _isLoadingLocation
                              ? SizedBox(
                                  width: 18.sp,
                                  height: 18.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                          label: Text(
                            _isLoadingLocation
                                ? "Getting Location..."
                                : "Current Location",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E4A7B),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width < 600 ? 15.h : 30.h,
                ),

                // Responsive 3-Widget Layout
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine grid layout based on available width
                      bool isMobile = constraints.maxWidth < 800;
                      bool isTablet =
                          constraints.maxWidth >= 800 &&
                          constraints.maxWidth < 1200;

                      if (isMobile) {
                        // Single column for mobile - make it scrollable with fixed heights
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Column(
                            children: [
                              // Weather widget - bigger and more prominent on mobile
                              SizedBox(
                                height: 550.h,
                                child: WeatherWidget(
                                  isDarkMode: _isDarkMode,
                                  onWeatherUpdate: (weather, city, forecast) {
                                    setState(() {
                                      _currentWeather = weather;
                                      _currentCity = city;
                                      _weatherForecast = forecast;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 20.h),
                              // Agenda widget
                              SizedBox(
                                height: 650.h,
                                child: AgendaWidget(
                                  isDarkMode: _isDarkMode,
                                  onPlansUpdate: (plans) {
                                    setState(() {
                                      _plans = plans;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 20.h),
                              // Chatbot widget
                              SizedBox(
                                height: 550.h,
                                child: ChatbotWidget(
                                  isDarkMode: _isDarkMode,
                                  plans: _plans,
                                  weather: _currentWeather,
                                  cityName: _currentCity,
                                  weatherForecast: _weatherForecast,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (isTablet) {
                        // 2 columns for tablet
                        // Top: Weather | Agenda
                        // Bottom: Chatbot (full width)
                        return Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: WeatherWidget(
                                      isDarkMode: _isDarkMode,
                                      onWeatherUpdate:
                                          (weather, city, forecast) {
                                            setState(() {
                                              _currentWeather = weather;
                                              _currentCity = city;
                                              _weatherForecast = forecast;
                                            });
                                          },
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: AgendaWidget(
                                      isDarkMode: _isDarkMode,
                                      onPlansUpdate: (plans) {
                                        setState(() {
                                          _plans = plans;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Expanded(
                              child: ChatbotWidget(
                                isDarkMode: _isDarkMode,
                                plans: _plans,
                                weather: _currentWeather,
                                cityName: _currentCity,
                                weatherForecast: _weatherForecast,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // 3 columns for desktop
                        // Weather (left) | Agenda (middle) | Chatbot (right)
                        return Row(
                          children: [
                            Expanded(
                              child: WeatherWidget(
                                isDarkMode: _isDarkMode,
                                onWeatherUpdate: (weather, city, forecast) {
                                  setState(() {
                                    _currentWeather = weather;
                                    _currentCity = city;
                                    _weatherForecast = forecast;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: AgendaWidget(
                                isDarkMode: _isDarkMode,
                                onPlansUpdate: (plans) {
                                  setState(() {
                                    _plans = plans;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: ChatbotWidget(
                                isDarkMode: _isDarkMode,
                                plans: _plans,
                                weather: _currentWeather,
                                cityName: _currentCity,
                                weatherForecast: _weatherForecast,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),

                // Footer - responsive
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width < 600
                        ? 10.h
                        : 12.h,
                    horizontal: 10.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: _isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: MediaQuery.of(context).size.width < 600
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.code,
                                  size: 14.sp,
                                  color: _isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "Made with ❤️",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: _isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Mohamed ElAmine Haj Mohamed",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode
                                    ? Colors.blue[300]
                                    : const Color(0xFF1E4A7B),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.code,
                              size: 16.sp,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Made by ",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: _isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            Text(
                              "Mohamed ElAmine Haj Mohamed",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode
                                    ? Colors.blue[300]
                                    : const Color(0xFF1E4A7B),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "© ${DateTime.now().year}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _isDarkMode
                                    ? Colors.white60
                                    : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
