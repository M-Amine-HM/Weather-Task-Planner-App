import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weatherwebapp/plannerPage.dart';

class Weatherpage extends StatefulWidget {
  const Weatherpage({super.key});

  @override
  State<Weatherpage> createState() => _WeatherpageState();
}

class _WeatherpageState extends State<Weatherpage> {
  bool _isDarkMode = false;
  String _isDarkModeString = "Dark Mode";
  String _isLightModeString = "Light Mode";
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _isDarkMode
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 43, 43, 43),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // Purple
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 43, 43, 43),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
            child: Column(
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
                    SizedBox(width: 50.w),
                    Container(
                      width: 600.w,

                      //height: 50.h, // Adjust width as needed
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        //vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: _isDarkMode ? Colors.white : Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: _isDarkMode ? Colors.white : Colors.black87,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller:
                                  _searchController, // your TextEditingController
                              style: TextStyle(
                                color: _isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16.sp,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search city or country...',
                                hintStyle: TextStyle(
                                  color: _isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.5),
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.w),
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
                        // TODO: Add your logic to get current location
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Plannerpage(),
                          ),
                        );
                      },
                      child: Text(
                        "My Planner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button color
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
                SizedBox(height: 60.h),
                Row(
                  children: [
                    Container(
                      width: 400.w,
                      height: 280.h,
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[350],
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: _isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40.w),
                    Container(
                      width: 800.w,
                      height: 280.h,
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[350],
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: _isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  children: [
                    Container(
                      width: 340.w,
                      height: 320.h,
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[350],
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: _isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40.w),
                    Container(
                      width: 860.w,
                      height: 320.h,
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[350],
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: _isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
