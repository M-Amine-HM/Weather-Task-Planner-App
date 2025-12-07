import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weatherwebapp/agendaPage.dart';
import 'package:weatherwebapp/chatbotwidget.dart';
import 'package:weatherwebapp/weatherPage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isDarkMode = false;

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
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
            child: Column(
              children: [
                // Header with App Title, Dark Mode Toggle and Current Location
                Row(
                  children: [
                    // App Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WeatherPlanner",
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode
                                ? Colors.white
                                : const Color(0xFF1E4A7B),
                          ),
                        ),
                        Text(
                          "Plan Smarter with Weather Insights",
                          style: TextStyle(
                            fontSize: 14.sp,
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
                        color: _isDarkMode ? Colors.grey[800] : Colors.white,
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
                            color: _isDarkMode ? Colors.grey : Colors.orange,
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
                            color: _isDarkMode ? Colors.blue[300] : Colors.grey,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.w),

                    // Current Location Button
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Add your logic to get current location
                      },
                      icon: Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      label: Text(
                        "Current Location",
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
                ),
                SizedBox(height: 30.h),

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
                        // Single column for mobile
                        return ListView(
                          children: [
                            SizedBox(
                              height: 450.h,
                              child: WeatherWidget(isDarkMode: _isDarkMode),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              height: 500.h,
                              child: AgendaWidget(isDarkMode: _isDarkMode),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              height: 450.h,
                              child: ChatbotWidget(isDarkMode: _isDarkMode),
                            ),
                          ],
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
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: AgendaWidget(
                                      isDarkMode: _isDarkMode,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Expanded(
                              child: ChatbotWidget(isDarkMode: _isDarkMode),
                            ),
                          ],
                        );
                      } else {
                        // 3 columns for desktop
                        // Weather (left) | Agenda (middle) | Chatbot (right)
                        return Row(
                          children: [
                            Expanded(
                              child: WeatherWidget(isDarkMode: _isDarkMode),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: AgendaWidget(isDarkMode: _isDarkMode),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: ChatbotWidget(isDarkMode: _isDarkMode),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),

                // Footer
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.code,
                        size: 16.sp,
                        color: _isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Made with ❤️ by ",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _isDarkMode ? Colors.white70 : Colors.black54,
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
                          color: _isDarkMode ? Colors.white60 : Colors.black45,
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
