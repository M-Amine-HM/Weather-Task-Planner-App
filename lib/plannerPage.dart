import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weatherwebapp/agendaPage.dart';
import 'package:weatherwebapp/weatherPage.dart';

class Plannerpage extends StatefulWidget {
  const Plannerpage({super.key});

  @override
  State<Plannerpage> createState() => _PlannerpageState();
}

class _PlannerpageState extends State<Plannerpage> {
  bool _isDarkMode = false;
  String _isDarkModeString = "Dark Mode";
  String _isLightModeString = "Light Mode";
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                        _isDarkMode ? _isDarkModeString : _isLightModeString,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add your logic to get current location
                    },
                    icon: Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    label: Text(
                      "Current Location",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 25.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      elevation: 4,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Agendapage()),
                      );
                    },
                    child: Text(
                      "Agenda",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Button color
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 25.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      elevation: 4,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Weatherpage()),
                      );
                    },
                    child: Text(
                      "Weather",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade900, // Button color
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 25.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 80.h),

              // 💡 Center Add Plan Card
              Expanded(
                child: Center(
                  child: Container(
                    width: 700.w,
                    height: 600.h,
                    padding: EdgeInsets.all(40.w),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[850] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(8, 10),
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
                            fontSize: 28.sp,
                            color: _isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Activity TextField
                        TextField(
                          style: TextStyle(fontSize: 18.sp),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.edit,
                              color: Colors.grey[600],
                              size: 26.sp,
                            ),
                            hintText: "Go jogging",
                            hintStyle: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[500],
                            ),
                            filled: true,
                            fillColor: _isDarkMode
                                ? Colors.grey[800]
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20.h,
                              horizontal: 20.w,
                            ),
                          ),
                        ),
                        SizedBox(height: 25.h),

                        // Date & Time Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                style: TextStyle(fontSize: 18.sp),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 24.sp,
                                  ),
                                  hintText: "Jul 25, 2024",
                                  hintStyle: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey[500],
                                  ),
                                  filled: true,
                                  fillColor: _isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.h,
                                    horizontal: 20.w,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                style: TextStyle(fontSize: 18.sp),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.access_time,
                                    size: 24.sp,
                                  ),
                                  hintText: "06:00 AM",
                                  hintStyle: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey[500],
                                  ),
                                  filled: true,
                                  fillColor: _isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.h,
                                    horizontal: 20.w,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25.h),

                        // Advice Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? Colors.grey[800]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            "It might rain during your picnic — consider moving it earlier or bringing a tent ☔",
                            style: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black87,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Refresh Advice",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E4A7B),
                              padding: EdgeInsets.symmetric(
                                horizontal: 30.w,
                                vertical: 18.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
