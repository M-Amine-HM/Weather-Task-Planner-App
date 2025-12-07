import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlannerWidget extends StatefulWidget {
  final bool isDarkMode;

  const PlannerWidget({super.key, required this.isDarkMode});

  @override
  State<PlannerWidget> createState() => _PlannerWidgetState();
}

class _PlannerWidgetState extends State<PlannerWidget> {
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
            "Add Your Plan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),

          // Activity TextField
          TextField(
            style: TextStyle(fontSize: 16.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.edit,
                color: Colors.grey[600],
                size: 22.sp,
              ),
              hintText: "Go jogging",
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
          SizedBox(height: 15.h),

          // Date & Time Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today, size: 20.sp),
                    hintText: "Jul 25, 2024",
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
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
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: TextField(
                  readOnly: true,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, size: 20.sp),
                    hintText: "06:00 AM",
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
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
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // Advice Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: SingleChildScrollView(
                child: Text(
                  "It might rain during your picnic — consider moving it earlier or bringing a tent ☔",
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black87,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),

          // Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                "Refresh Advice",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4A7B),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
