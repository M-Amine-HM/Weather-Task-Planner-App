import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weatherwebapp/weatherPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // This is the reference size you used when designing (mobile or web)
      designSize: const Size(1440, 900), // Recommended base for web layouts
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather Web App',
          theme: ThemeData(useMaterial3: true),
          home: child,
        );
      },
      child: const Weatherpage(),
    );
  }
}
