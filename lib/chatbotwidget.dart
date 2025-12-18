import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'services/Api.dart';
import 'models/plan_model.dart';
import 'models/weather_model.dart';

class ChatbotWidget extends StatefulWidget {
  final bool isDarkMode;
  final List<Plan>? plans;
  final Weather? weather;
  final String? cityName;
  final List<Map<String, dynamic>>? weatherForecast;

  const ChatbotWidget({
    super.key,
    required this.isDarkMode,
    this.plans,
    this.weather,
    this.cityName,
    this.weatherForecast,
  });

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hello! I can help you plan your activities based on weather forecasts. Ask me anything!',
      'isUser': false,
      'time': '10:00 AM',
    },
  ];

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': true,
        'time': TimeOfDay.now().format(context),
      });
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Build context from weather and plans
      String? aiContext = _buildContext();

      // Debug: Print context being sent
      print('=== Sending to AI ===');
      print('User message: $userMessage');
      print('Context length: ${aiContext?.length ?? 0} characters');
      if (aiContext != null) {
        print(
          'Context preview:\n${aiContext.substring(0, aiContext.length > 200 ? 200 : aiContext.length)}...',
        );
      }

      // Send message to AI with context
      String? aiResponse = await Api.sendChatMessage(
        userMessage,
        context: aiContext,
      );
      if (aiResponse != null) {
        setState(() {
          _messages.add({
            'text': aiResponse,
            'isUser': false,
            'time': TimeOfDay.now().format(this.context),
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add({
            'text':
                'Sorry, I couldn\'t process your request. Please try again.',
            'isUser': false,
            'time': TimeOfDay.now().format(this.context),
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      String errorMessage =
          'Error connecting to AI service. Please check your connection.';

      // Check for quota exceeded error
      if (e.toString().contains('exceeded your current quota') ||
          e.toString().contains('429')) {
        errorMessage =
            'AI service quota exceeded. Please try again later or contact support.';
      }

      setState(() {
        _messages.add({
          'text': errorMessage,
          'isUser': false,
          'time': TimeOfDay.now().format(this.context),
        });
        _isLoading = false;
      });
      print('Chat error: $e');
    }

    _scrollToBottom();
  }

  String? _buildContext() {
    // Build context string from plans and weather data
    StringBuffer context = StringBuffer();

    // Add weather information
    if (widget.weather != null) {
      context.writeln('=== CURRENT WEATHER ===');
      context.writeln('Location: ${widget.cityName ?? "Unknown"}');
      context.writeln(
        'Temperature: ${widget.weather!.temperature}°C (Feels like: ${widget.weather!.feelsLike}°C)',
      );
      context.writeln('Condition: ${widget.weather!.condition}');
      context.writeln('Description: ${widget.weather!.description}');
      context.writeln('Humidity: ${widget.weather!.humidity}%');
      context.writeln('Wind Speed: ${widget.weather!.windSpeed} km/h');
      context.writeln('');
    }

    // Add weather forecast information
    if (widget.weatherForecast != null && widget.weatherForecast!.isNotEmpty) {
      context.writeln('=== 7-DAY WEATHER FORECAST ===');
      context.writeln('Location: ${widget.cityName ?? "Unknown"}');
      context.writeln('');

      int daysToShow = widget.weatherForecast!.length > 7
          ? 7
          : widget.weatherForecast!.length;
      for (int i = 0; i < daysToShow; i++) {
        var forecast = widget.weatherForecast![i];
        String date = forecast['date'] ?? 'Unknown date';
        String dateFormatted = _formatForecastDate(date, i);

        context.writeln('$dateFormatted:');
        context.writeln(
          '  Max: ${forecast['temperature_max']}°C, Min: ${forecast['temperature_min']}°C',
        );
        context.writeln(
          '  Condition: ${forecast['condition']} - ${forecast['description']}',
        );
      }
      context.writeln('');
    }

    // Add plans information with better formatting
    if (widget.plans != null && widget.plans!.isNotEmpty) {
      context.writeln('=== USER\'S PLANS (Total: ${widget.plans!.length}) ===');

      // Group plans by date for better organization
      Map<String, List<Plan>> plansByDate = {};
      for (var plan in widget.plans!) {
        String dateStr = plan.date != null
            ? _formatDate(plan.date!)
            : 'No specific date';
        if (!plansByDate.containsKey(dateStr)) {
          plansByDate[dateStr] = [];
        }
        plansByDate[dateStr]!.add(plan);
      }

      // Output plans organized by date
      plansByDate.forEach((date, plans) {
        context.writeln('\n📅 $date:');
        for (var plan in plans) {
          context.writeln('  • ${plan.title}');
          context.writeln('    Details: ${plan.description}');
        }
      });
      context.writeln('');
    } else {
      context.writeln('=== USER\'S PLANS ===');
      context.writeln('No plans created yet.');
      context.writeln('');
    }

    return context.isEmpty ? null : context.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final planDate = DateTime(date.year, date.month, date.day);

    if (planDate == today) {
      return 'Today (${date.day}/${date.month}/${date.year})';
    } else if (planDate == tomorrow) {
      return 'Tomorrow (${date.day}/${date.month}/${date.year})';
    } else {
      final daysUntil = planDate.difference(today).inDays;
      if (daysUntil > 0 && daysUntil < 7) {
        return 'In $daysUntil days (${date.day}/${date.month}/${date.year})';
      } else if (daysUntil < 0 && daysUntil > -7) {
        return '${daysUntil.abs()} days ago (${date.day}/${date.month}/${date.year})';
      }
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatForecastDate(String dateStr, int dayIndex) {
    try {
      DateTime date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final forecastDate = DateTime(date.year, date.month, date.day);

      final daysFromNow = forecastDate.difference(today).inDays;

      if (daysFromNow == 0) {
        return '📍 Today (${date.day}/${date.month})';
      } else if (daysFromNow == 1) {
        return '📍 Tomorrow (${date.day}/${date.month})';
      } else if (daysFromNow > 1 && daysFromNow <= 7) {
        return '📍 In $daysFromNow days (${date.day}/${date.month})';
      } else {
        return '📍 ${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '📍 Day ${dayIndex + 1}';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        gradient: widget.isDarkMode
            ? LinearGradient(
                colors: [Colors.grey[850]!, Colors.grey[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.purple[50]!, Colors.purple[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: widget.isDarkMode
                    ? Colors.purple[300]
                    : const Color(0xFF1E4A7B),
                size: 28.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                "Weather Assistant",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Chat Messages
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: widget.isDarkMode
                                  ? Colors.purple[300]
                                  : const Color(0xFF1E4A7B),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'AI is thinking...',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),

          // Message Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(fontSize: 16.sp),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Ask about weather impact on your plans...",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
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
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4A7B),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white, size: 22.sp),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message['isUser'];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 300.w),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF1E4A7B)
              : (widget.isDarkMode ? Colors.grey[700] : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: isUser ? Radius.circular(12.r) : Radius.zero,
            bottomRight: isUser ? Radius.zero : Radius.circular(12.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'],
              style: TextStyle(
                fontSize: 14.sp,
                color: isUser
                    ? Colors.white
                    : (widget.isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message['time'],
              style: TextStyle(
                fontSize: 11.sp,
                color: isUser
                    ? Colors.white70
                    : (widget.isDarkMode ? Colors.white60 : Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
