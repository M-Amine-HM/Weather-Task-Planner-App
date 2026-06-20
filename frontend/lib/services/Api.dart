import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../models/plan_model.dart'; // TODO: re-enable when database is added
import '../models/weather_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Api {
  static String get baseUrl => "http://localhost:8000";

  // ── COMMENTED OUT: Plan API methods (no database for now) ─────────────────
  // TODO: re-enable all methods below when MongoDB is added back

  // static Future<void> addPlan(Map<String, String> pdata) async {
  //   print("Adding plan: $pdata");
  //   var url = Uri.parse("$baseUrl/plans/addplan/");
  //   try {
  //     final res = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(pdata),
  //     );
  //     if (res.statusCode == 200) {
  //       var data = jsonDecode(res.body.toString());
  //       print("Plan added successfully: $data");
  //     } else {
  //       print("Error adding plan: Status ${res.statusCode}");
  //       print("Response: ${res.body}");
  //     }
  //   } catch (e) {
  //     print("Error adding plan: $e");
  //     rethrow;
  //   }
  // }

  // static Future<List<Plan>> getPlans() async {
  //   List<Plan> plans = [];
  //   var url = Uri.parse("$baseUrl/plans/getallplans/");
  //   try {
  //     final res = await http.get(url);
  //     if (res.statusCode == 200) {
  //       var data = jsonDecode(res.body.toString());
  //       List plansList;
  //       if (data is List) {
  //         plansList = data;
  //       } else if (data is Map && data.containsKey('plans')) {
  //         plansList = data['plans'] as List;
  //       } else {
  //         print("Unexpected data structure: $data");
  //         return [];
  //       }
  //       for (var value in plansList) {
  //         try {
  //           plans.add(Plan.fromJson(value));
  //         } catch (e) {
  //           print("Error parsing plan: $e, value: $value");
  //         }
  //       }
  //       print("Fetched ${plans.length} plans successfully");
  //       return plans;
  //     } else {
  //       print("Error: Status code ${res.statusCode}");
  //       return [];
  //     }
  //   } catch (e) {
  //     print("Error fetching plans: $e");
  //     return [];
  //   }
  // }

  // static Future<Plan?> getPlanById(String planId) async {
  //   var url = Uri.parse("$baseUrl/plans/$planId");
  //   try {
  //     final res = await http.get(url);
  //     if (res.statusCode == 200) {
  //       var data = jsonDecode(res.body.toString());
  //       return Plan.fromJson(data);
  //     } else if (res.statusCode == 404) {
  //       print("Plan not found");
  //       return null;
  //     } else {
  //       print("Error: Status code ${res.statusCode}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Error fetching plan: $e");
  //     rethrow;
  //   }
  // }

  // static Future<List<Plan>> searchPlansByTitle(String title) async {
  //   List<Plan> plans = [];
  //   var url = Uri.parse("$baseUrl/plans/search/$title");
  //   try {
  //     final res = await http.get(url);
  //     if (res.statusCode == 200) {
  //       var data = jsonDecode(res.body.toString());
  //       List plansList = data is List ? data : [];
  //       for (var value in plansList) {
  //         try {
  //           plans.add(Plan.fromJson(value));
  //         } catch (e) {
  //           print("Error parsing plan: $e");
  //         }
  //       }
  //       return plans;
  //     } else if (res.statusCode == 404) {
  //       return [];
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     print("Error searching plans: $e");
  //     return [];
  //   }
  // }

  // static Future<bool> updatePlan(String planId, Map<String, String> pdata) async {
  //   print("Updating plan $planId: $pdata");
  //   var url = Uri.parse("$baseUrl/plans/modifyplan/$planId");
  //   try {
  //     final res = await http.put(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(pdata),
  //     );
  //     if (res.statusCode == 200) {
  //       return true;
  //     } else if (res.statusCode == 404) {
  //       print("Plan not found");
  //       return false;
  //     } else {
  //       print("Error updating plan: Status ${res.statusCode}");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Error updating plan: $e");
  //     rethrow;
  //   }
  // }

  // static Future<bool> deletePlan(String planId) async {
  //   print("Deleting plan: $planId");
  //   var url = Uri.parse("$baseUrl/plans/deleteplan/$planId");
  //   try {
  //     final res = await http.delete(url);
  //     if (res.statusCode == 200) {
  //       return true;
  //     } else if (res.statusCode == 404) {
  //       print("Plan not found");
  //       return false;
  //     } else {
  //       print("Error deleting plan: Status ${res.statusCode}");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Error deleting plan: $e");
  //     rethrow;
  //   }
  // }

  // ─────────────────────────────────────────────────────────────────────────

  // ── Weather API methods (active) ──────────────────────────────────────────

  static Future<Weather?> getCurrentWeather(String city) async {
    var url = Uri.parse("$baseUrl/weather/current/$city");
    try {
      print("Fetching current weather for $city");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        return Weather.fromJson(data);
      } else if (res.statusCode == 404) {
        print("City not found: ${res.body}");
        return null;
      } else {
        print("Error: Status code ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching weather: $e");
      rethrow;
    }
  }

  static Future<Weather?> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    var url = Uri.parse("$baseUrl/weather/current/coords?lat=$lat&lon=$lon");
    try {
      print("Fetching weather for coordinates: $lat, $lon");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        return Weather.fromJson(data);
      } else if (res.statusCode == 404) {
        print("Location not found: ${res.body}");
        return null;
      } else {
        print("Error: Status code ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching weather by coordinates: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getWeatherForecast(
    String city, {
    int days = 7,
  }) async {
    var url = Uri.parse("$baseUrl/weather/forecast/$city?days=$days");
    try {
      print("Fetching forecast for $city");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        return jsonDecode(res.body.toString());
      } else if (res.statusCode == 404) {
        print("City not found for forecast");
        return null;
      } else {
        print("Error: Status code ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching forecast: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getForecastByCoordinates(
    double lat,
    double lon, {
    int days = 7,
  }) async {
    var url = Uri.parse(
      "$baseUrl/weather/forecast/coords?lat=$lat&lon=$lon&days=$days",
    );
    try {
      print("Fetching forecast for coordinates: $lat, $lon");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        return jsonDecode(res.body.toString());
      } else if (res.statusCode == 404) {
        print("Location not found for forecast");
        return null;
      } else {
        print("Error: Status code ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching forecast by coordinates: $e");
      rethrow;
    }
  }

  // ── AI Chat API method (active) ───────────────────────────────────────────

  static Future<String?> sendChatMessage(
    String message, {
    String? context,
  }) async {
    var url = Uri.parse("$baseUrl/chat/ask");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'message': message, 'context': context}),
      );
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        print("AI response received");
        return data['response'];
      } else {
        print("Error: Status code ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error sending chat message: $e");
      rethrow;
    }
  }
}
