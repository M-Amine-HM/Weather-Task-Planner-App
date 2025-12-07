import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weatherwebapp/agendaPage.dart';
import 'package:weatherwebapp/plannerPage.dart';
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
                    Color.fromARGB(255, 43, 43, 43),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 43, 43, 43),
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
                // Header with Dark Mode Toggle and Current Location
                Row(
                  children: [
                    // Dark Mode Toggle
                    Column(
                      children: [
                        Switch(
                          value: _isDarkMode,
                          activeColor: Colors.black,
                          inactiveThumbColor: Colors.black,
                          activeTrackColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              _isDarkMode = value;
                            });
                          },
                        ),
                        Text(
                          _isDarkMode ? "Dark Mode" : "Light Mode",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

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
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
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

                // Responsive Grid Layout
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine grid layout based on available width
                      bool isMobile = constraints.maxWidth < 600;
                      bool isTablet =
                          constraints.maxWidth >= 600 &&
                          constraints.maxWidth < 1200;

                      int crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
                      double spacing = isMobile ? 15 : 20;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: isMobile ? 0.8 : 1.0,
                        children: [
                          // Weather Widget
                          WeatherWidget(isDarkMode: _isDarkMode),

                          // Agenda Widget
                          AgendaWidget(isDarkMode: _isDarkMode),

                          // Planner Widget
                          PlannerWidget(isDarkMode: _isDarkMode),
                        ],
                      );
                    },
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
