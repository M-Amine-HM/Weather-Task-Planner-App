import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/plan_model.dart';
import 'services/Api.dart';

class AgendaWidget extends StatefulWidget {
  final bool isDarkMode;
  final Function(List<Plan> plans)? onPlansUpdate;

  const AgendaWidget({super.key, required this.isDarkMode, this.onPlansUpdate});

  @override
  State<AgendaWidget> createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, List<Plan>> _plans = {}; // Store plans by date key

  @override
  void initState() {
    super.initState();
    _loadPlansFromBackend();
  }

  Future<void> _loadPlansFromBackend() async {
    try {
      List<Plan> fetchedPlans = await Api.getPlans();

      if (fetchedPlans.isNotEmpty) {
        setState(() {
          // Clear existing plans
          _plans.clear();

          // Organize plans by their date
          for (var plan in fetchedPlans) {
            // Use the plan's date if available, otherwise use today
            DateTime planDate = plan.date ?? DateTime.now();
            String key = _getDateKey(planDate);

            if (_plans[key] == null) {
              _plans[key] = [];
            }
            _plans[key]!.add(plan);
          }
        });
        // Notify parent dashboard about plans update
        widget.onPlansUpdate?.call(fetchedPlans);
      }
    } catch (e) {
      print('Error loading plans: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load plans from server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void _notifyPlansUpdate() {
    // Get all plans as a flat list
    List<Plan> allPlans = [];
    _plans.forEach((key, plansList) {
      allPlans.addAll(plansList);
    });
    widget.onPlansUpdate?.call(allPlans);
  }

  List<Plan> _getPlansForDay(DateTime day) {
    return _plans[_getDateKey(day)] ?? [];
  }

  Future<void> _addPlan(DateTime day, Plan plan) async {
    try {
      // Set the plan's date
      plan.date = day;

      // Send to backend with date
      await Api.addPlan({
        'title': plan.title,
        'description': plan.description,
        'date': day.toIso8601String(),
      });

      // Add to local state
      String key = _getDateKey(day);
      if (_plans[key] == null) {
        _plans[key] = [];
      }
      _plans[key]!.add(plan);

      // Notify parent about plans update
      _notifyPlansUpdate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error adding plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add plan to server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePlan(DateTime day, Plan plan, int index) async {
    try {
      // Delete from backend if plan has an ID
      if (plan.id.isNotEmpty) {
        bool success = await Api.deletePlan(plan.id);
        if (!success) {
          throw Exception('Failed to delete from server');
        }
      }

      // Remove from local state
      setState(() {
        String key = _getDateKey(day);
        _plans[key]!.removeAt(index);
        if (_plans[key]!.isEmpty) {
          _plans.remove(key);
        }
      });

      // Notify parent about plans update
      _notifyPlansUpdate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Reopen dialog to show updated list
        Future.delayed(Duration(milliseconds: 300), () {
          _showPlanDialog(day);
        });
      }
    } catch (e) {
      print('Error deleting plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete plan from server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePlan(
    DateTime day,
    Plan oldPlan,
    Plan newPlan,
    int index,
  ) async {
    try {
      // Update on backend if plan has an ID
      if (newPlan.id.isNotEmpty) {
        bool success = await Api.updatePlan(newPlan.id, {
          'title': newPlan.title,
          'description': newPlan.description,
          'date': newPlan.date?.toIso8601String() ?? day.toIso8601String(),
        });
        if (!success) {
          throw Exception('Failed to update on server');
        }
      }

      // Update in local state
      setState(() {
        String key = _getDateKey(day);
        _plans[key]![index] = newPlan;
      });

      // Notify parent about plans update
      _notifyPlansUpdate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update plan on server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPlanDialog(DateTime selectedDay) {
    List<Plan> existingPlans = _getPlansForDay(selectedDay);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 500.w, maxHeight: 600.h),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plans for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: widget.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Existing plans
                if (existingPlans.isNotEmpty) ...[
                  Text(
                    'Existing Plans:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: existingPlans.length,
                      itemBuilder: (context, index) {
                        Plan plan = existingPlans[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.title,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: widget.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      plan.description,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: widget.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showEditPlanDialog(
                                        selectedDay,
                                        plan,
                                        index,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _deletePlan(
                                        selectedDay,
                                        plan,
                                        index,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Divider(
                    color: widget.isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  SizedBox(height: 16.h),
                ],

                // Add new plan button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddPlanDialog(selectedDay);
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add New Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPlanDialog(DateTime selectedDay) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400.w),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Add Plan',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title field
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: widget.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Description field
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: widget.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          await _addPlan(
                            selectedDay,
                            Plan(
                              id: '', // Backend will assign ID
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              date: selectedDay,
                            ),
                          );
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditPlanDialog(DateTime selectedDay, Plan plan, int index) {
    TextEditingController titleController = TextEditingController(
      text: plan.title,
    );
    TextEditingController descriptionController = TextEditingController(
      text: plan.description,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400.w),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Edit Plan',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title field
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: widget.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Description field
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: widget.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          Plan updatedPlan = Plan(
                            id: plan.id,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            date: plan.date ?? selectedDay,
                          );
                          await _updatePlan(
                            selectedDay,
                            plan,
                            updatedPlan,
                            index,
                          );
                          // Reopen dialog to show updated plan
                          Future.delayed(Duration(milliseconds: 300), () {
                            _showPlanDialog(selectedDay);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                        _showPlanDialog(selectedDay);
                      },
                      eventLoader: (day) {
                        return _getPlansForDay(day);
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
                        markerDecoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        markerSize: 7.0,
                        markersMaxCount: 1,
                        canMarkersOverflow: false,
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
