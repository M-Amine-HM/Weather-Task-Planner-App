import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Column(
              children: [
                Row(
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
                    SizedBox(width: 15.w),
                    Container(
                      width: 300.w, // Adjust width as needed
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: _isDarkMode
                              ? Colors.white.withOpacity(0.4)
                              : Colors.black.withOpacity(0.2),
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
