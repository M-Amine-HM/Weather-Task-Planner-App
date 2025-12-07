import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeatherWidget extends StatefulWidget {
  final bool isDarkMode;

  const WeatherWidget({super.key, required this.isDarkMode});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Weather Forecast",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),

          // Search Bar
          TextField(
            style: TextStyle(fontSize: 16.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 22.sp,
              ),
              hintText: "Search city or country...",
              hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
              filled: true,
              fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 16.w,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Weather Data Placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, size: 80.sp, color: Colors.orange),
                    SizedBox(height: 20.h),
                    Text(
                      "Weather data will appear here",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: widget.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
