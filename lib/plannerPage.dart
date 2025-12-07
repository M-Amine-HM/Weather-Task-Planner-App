import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlannerWidget extends StatefulWidget {
  final bool isDarkMode;

  const PlannerWidget({super.key, required this.isDarkMode});

  @override
  State<PlannerWidget> createState() => _PlannerWidgetState();
}

class _PlannerWidgetState extends State<PlannerWidget> {
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // TODO: Replace with actual data from database
  List<Map<String, String>> _plans = [];

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
                colors: [Colors.green[50]!, Colors.green[100]!],
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
                Icons.event_note,
                color: widget.isDarkMode
                    ? Colors.green[300]
                    : const Color(0xFF1E4A7B),
                size: 28.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                "Add Your Plan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Activity TextField
          TextField(
            controller: _activityController,
            style: TextStyle(fontSize: 16.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.edit,
                color: Colors.grey[600],
                size: 22.sp,
              ),
              labelText: "Activity",
              hintText: "Go jogging, Meeting, etc.",
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
                  controller: _dateController,
                  readOnly: true,
                  style: TextStyle(fontSize: 16.sp),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateController.text =
                            "${picked.day}/${picked.month}/${picked.year}";
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today, size: 20.sp),
                    labelText: "Date",
                    hintText: "Select date",
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
                  controller: _timeController,
                  readOnly: true,
                  style: TextStyle(fontSize: 16.sp),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _timeController.text = picked.format(context);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, size: 20.sp),
                    labelText: "Time",
                    hintText: "Select time",
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
          SizedBox(height: 20.h),

          // Saved Plans List
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: _plans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 60.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "No plans yet",
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _plans.length,
                      itemBuilder: (context, index) {
                        return _buildPlanItem(_plans[index]);
                      },
                    ),
            ),
          ),
          SizedBox(height: 15.h),

          // Add Plan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_activityController.text.isNotEmpty &&
                    _dateController.text.isNotEmpty &&
                    _timeController.text.isNotEmpty) {
                  setState(() {
                    _plans.add({
                      'activity': _activityController.text,
                      'date': _dateController.text,
                      'time': _timeController.text,
                    });
                    _activityController.clear();
                    _dateController.clear();
                    _timeController.clear();
                  });
                  // TODO: Save to database
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                "Add Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4A7B),
                padding: EdgeInsets.symmetric(vertical: 16.h),
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

  Widget _buildPlanItem(Map<String, String> plan) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[700] : Colors.blue[50],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: widget.isDarkMode ? Colors.grey[600]! : Colors.blue[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            color: widget.isDarkMode
                ? Colors.blue[300]
                : const Color(0xFF1E4A7B),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['activity']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${plan['date']} at ${plan['time']}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[400], size: 22.sp),
            onPressed: () {
              setState(() {
                _plans.remove(plan);
              });
              // TODO: Delete from database
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _activityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
