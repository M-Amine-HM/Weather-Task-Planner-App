import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatbotWidget extends StatefulWidget {
  final bool isDarkMode;

  const ChatbotWidget({super.key, required this.isDarkMode});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // TODO: Replace with actual chatbot responses
  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hello! I can help you plan your activities based on weather forecasts. Ask me anything!',
      'isUser': false,
      'time': '10:00 AM',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isUser': true,
        'time': TimeOfDay.now().format(context),
      });

      // TODO: Replace with actual AI response
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'text':
                'Based on the weather forecast, it might rain during your picnic on Saturday. Consider moving it earlier or bringing a tent ☔',
            'isUser': false,
            'time': TimeOfDay.now().format(context),
          });
        });
        _scrollToBottom();
      });
    });

    _messageController.clear();
    _scrollToBottom();
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
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
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
