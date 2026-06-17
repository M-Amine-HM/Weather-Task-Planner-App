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

  // Bottom nav index (mobile only)
  int _currentNavIndex = 0;

  // Nav labels and icons
  final List<Map<String, dynamic>> _navItems = [
    {
      'label': 'Weather',
      'icon': Icons.wb_sunny_rounded,
      'activeIcon': Icons.wb_sunny,
    },
    {
      'label': 'Plans',
      'icon': Icons.event_note_outlined,
      'activeIcon': Icons.event_note,
    },
    {
      'label': 'Chat',
      'icon': Icons.chat_bubble_outline_rounded,
      'activeIcon': Icons.chat_bubble_rounded,
    },
  ];

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      if (kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showMessage(
            'Location services are disabled. Please enable location in your browser.',
          );
          setState(() => _isLoadingLocation = false);
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _showMessage(
              'Location permission denied. Please allow location access.',
            );
            setState(() => _isLoadingLocation = false);
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          _showMessage('Location permissions are permanently denied.');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      await _fetchWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _showMessage('Failed to get location: ${e.toString()}');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _fetchWeatherByCoordinates(double lat, double lon) async {
    String cityName =
        'My Location (${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°)';

    try {
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
          if (forecastData != null && forecastData['forecast'] != null) {
            try {
              _weatherForecast = (forecastData['forecast'] as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
            } catch (e) {
              _weatherForecast = null;
            }
          }
        });
        _showMessage('Weather loaded for your location!');
      } else {
        _showMessage('Could not fetch weather for your location.');
      }
    } catch (e) {
      _showMessage('Failed to fetch weather: ${e.toString()}');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          backgroundColor: _isDarkMode
              ? Colors.grey[800]
              : const Color(0xFF1E4A7B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(bottom: 80.h, left: 16.w, right: 16.w),
        ),
      );
    }
  }

  // ── colors ──────────────────────────────────────────────────────────────────
  Color get _bgTop =>
      _isDarkMode ? const Color(0xFF1a1a2e) : const Color(0xFFe3f2fd);
  Color get _bgBot =>
      _isDarkMode ? const Color(0xFF0f3460) : const Color(0xFF90caf9);
  Color get _accent => const Color(0xFF1E4A7B);
  Color get _navBg => _isDarkMode ? const Color(0xFF1e2a40) : Colors.white;
  Color get _textPrimary =>
      _isDarkMode ? Colors.white : const Color(0xFF1E4A7B);
  Color get _textSecondary => _isDarkMode ? Colors.white70 : Colors.black54;

  // ── widgets for each tab ────────────────────────────────────────────────────
  Widget get _weatherWidget => WeatherWidget(
    isDarkMode: _isDarkMode,
    onWeatherUpdate: (weather, city, forecast) {
      setState(() {
        _currentWeather = weather;
        _currentCity = city;
        _weatherForecast = forecast;
      });
    },
  );

  Widget get _agendaWidget => AgendaWidget(
    isDarkMode: _isDarkMode,
    onPlansUpdate: (plans) {
      setState(() => _plans = plans);
    },
  );

  Widget get _chatWidget => ChatbotWidget(
    isDarkMode: _isDarkMode,
    plans: _plans,
    weather: _currentWeather,
    cityName: _currentCity,
    weatherForecast: _weatherForecast,
  );

  // ── header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader({bool compact = false}) {
    return Row(
      children: [
        // Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "WeatherPlanner",
              style: TextStyle(
                fontSize: compact ? 20 : 26,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            if (!compact)
              Text(
                "Plan Smarter with Weather Insights",
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
          ],
        ),
        const Spacer(),

        // Dark mode toggle
        GestureDetector(
          onTap: () => setState(() => _isDarkMode = !_isDarkMode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10.w : 14.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  color: _isDarkMode ? Colors.blue[300] : Colors.orange,
                  size: compact ? 18.sp : 20.sp,
                ),
                SizedBox(width: 6.w),
                Switch(
                  value: _isDarkMode,
                  activeColor: _accent,
                  inactiveThumbColor: Colors.orange,
                  activeTrackColor: Colors.blue[200],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (v) => setState(() => _isDarkMode = v),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: compact ? 8.w : 16.w),

        // Location button
        ElevatedButton.icon(
          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
          icon: _isLoadingLocation
              ? SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: compact ? 15.sp : 18.sp,
                ),
          label: Text(
            _isLoadingLocation
                ? "Getting..."
                : (compact ? "Location" : "Current Location"),
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 12.sp : 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12.w : 20.w,
              vertical: compact ? 10.h : 14.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            elevation: 3,
          ),
        ),
      ],
    );
  }

  // ── bottom nav bar (mobile) ─────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final bool isActive = _currentNavIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _currentNavIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _accent.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isActive
                              ? _navItems[index]['activeIcon'] as IconData
                              : _navItems[index]['icon'] as IconData,
                          key: ValueKey(isActive),
                          color: isActive ? _accent : _textSecondary,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _navItems[index]['label'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive ? _accent : _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── tab label banner (mobile, shows current section) ────────────────────────
  Widget _buildTabBanner() {
    final labels = ['Weather', 'My Plans', 'AI Assistant'];
    final icons = [
      Icons.wb_sunny_rounded,
      Icons.event_note,
      Icons.chat_bubble_rounded,
    ];
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _accent.withOpacity(_isDarkMode ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icons[_currentNavIndex], color: _accent, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            labels[_currentNavIndex],
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── footer ──────────────────────────────────────────────────────────────────
  Widget _buildFooter({bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 8.h : 12.h,
        horizontal: 10.w,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _isDarkMode
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            size: compact ? 13.sp : 15.sp,
            color: _textSecondary,
          ),
          SizedBox(width: 6.w),
          Text(
            "Made by ",
            style: TextStyle(
              fontSize: compact ? 11.sp : 12.sp,
              color: _textSecondary,
            ),
          ),
          Text(
            "Mohamed ElAmine Haj Mohamed",
            style: TextStyle(
              fontSize: compact ? 11.sp : 12.sp,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.blue[300] : _accent,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            "© ${DateTime.now().year}",
            style: TextStyle(
              fontSize: compact ? 10.sp : 11.sp,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── background gradient ──────────────────────────────────────────────────────
  BoxDecoration get _gradientBg => BoxDecoration(
    gradient: LinearGradient(
      colors: [_bgTop, _bgBot],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final isTablet = screenWidth >= 800 && screenWidth < 1200;

    return Scaffold(
      body: Container(
        decoration: _gradientBg,
        child: SafeArea(
          bottom: isMobile
              ? false
              : true, // let bottom nav handle safe area on mobile
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 12.h : 16.h,
                  horizontal: isMobile ? 16.w : 40.w,
                ),
                child: _buildHeader(compact: isMobile),
              ),

              // ── Content ─────────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.w : 40.w,
                  ),
                  child: isMobile
                      ? _buildMobileContent()
                      : isTablet
                      ? _buildTabletContent()
                      : _buildDesktopContent(),
                ),
              ),

              // ── Footer (desktop/tablet only) ─────────────────────────────────
              if (!isMobile) _buildFooter(),
            ],
          ),
        ),
      ),

      // ── Bottom Navigation (mobile only) ──────────────────────────────────────
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  // ── MOBILE: single tab view with bottom nav ──────────────────────────────────
  Widget _buildMobileContent() {
    return Column(
      children: [
        // Section label banner
        _buildTabBanner(),

        // Page content — IndexedStack keeps all 3 alive (no re-init on tab switch)
        Expanded(
          child: IndexedStack(
            index: _currentNavIndex,
            children: [_weatherWidget, _agendaWidget, _chatWidget],
          ),
        ),

        // Footer inside content area on mobile
        _buildFooter(compact: true),
      ],
    );
  }

  // ── TABLET: Weather + Agenda on top, Chat full-width below ──────────────────
  Widget _buildTabletContent() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _weatherWidget),
              SizedBox(width: 20.w),
              Expanded(child: _agendaWidget),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Expanded(child: _chatWidget),
      ],
    );
  }

  // ── DESKTOP: 3 equal columns ─────────────────────────────────────────────────
  Widget _buildDesktopContent() {
    return Row(
      children: [
        Expanded(child: _weatherWidget),
        SizedBox(width: 20.w),
        Expanded(child: _agendaWidget),
        SizedBox(width: 20.w),
        Expanded(child: _chatWidget),
      ],
    );
  }
}
