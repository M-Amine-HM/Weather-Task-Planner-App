import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weatherwebapp/dashboard.dart';
//import 'package:weatherwebapp/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Web App',
      theme: ThemeData(useMaterial3: true),
      home: LayoutBuilder(
        builder: (context, constraints) {
          // Use responsive design size based on screen width
          return ScreenUtilInit(
            designSize: constraints.maxWidth < 600
                ? const Size(375, 812) // Mobile
                : constraints.maxWidth < 1200
                ? const Size(768, 1024) // Tablet
                : const Size(1440, 900), // Desktop
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return child!;
            },
            child: const DashboardPage(),
          );
        },
      ),
    );
  }
}
