import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaWidget extends StatefulWidget {
  final bool isDarkMode;

  const AgendaWidget({super.key, required this.isDarkMode});

  @override
  State<AgendaWidget> createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

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
            "My Agenda",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),

          // Calendar
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Determine if we should use compact mode
                  bool isCompact =
                      constraints.maxWidth < 400 || constraints.maxHeight < 400;

                  return SingleChildScrollView(
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      // Responsive Calendar Style
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontSize: isCompact ? 12.sp : 14.sp,
                        ),
                        weekendTextStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: isCompact ? 12.sp : 14.sp,
                        ),
                        outsideTextStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white38
                              : Colors.black38,
                          fontSize: isCompact ? 12.sp : 14.sp,
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 12.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        selectedTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 12.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        // Responsive cell padding
                        cellPadding: EdgeInsets.all(isCompact ? 4.w : 8.w),
                        cellMargin: EdgeInsets.all(isCompact ? 2.w : 4.w),
                      ),
                      // Responsive Header Style
                      headerStyle: HeaderStyle(
                        formatButtonVisible: !isCompact,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        titleTextStyle: TextStyle(
                          fontSize: isCompact ? 16.sp : 18.sp,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                        formatButtonTextStyle: TextStyle(
                          fontSize: isCompact ? 12.sp : 14.sp,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                        formatButtonDecoration: BoxDecoration(
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.white38
                                : Colors.black38,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          size: isCompact ? 20.sp : 24.sp,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          size: isCompact ? 20.sp : 24.sp,
                        ),
                        headerPadding: EdgeInsets.symmetric(
                          vertical: isCompact ? 8.h : 12.h,
                        ),
                      ),
                      // Responsive Days of Week Style
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontSize: isCompact ? 12.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        weekendStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: isCompact ? 12.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Responsive sizing
                      daysOfWeekHeight: isCompact ? 30.h : 40.h,
                      rowHeight: isCompact ? 35.h : 48.h,
                      availableGestures: AvailableGestures.all,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
