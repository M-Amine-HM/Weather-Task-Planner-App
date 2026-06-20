import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/plan_model.dart';
// import 'services/Api.dart'; // TODO: re-enable when database is added

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
    // TODO: re-enable when database is added
    // _loadPlansFromBackend();
  }

  // ── COMMENTED OUT: Backend fetch ──────────────────────────────────────────
  // Future<void> _loadPlansFromBackend() async {
  //   try {
  //     List<Plan> fetchedPlans = await Api.getPlans();
  //     if (fetchedPlans.isNotEmpty) {
  //       setState(() {
  //         _plans.clear();
  //         for (var plan in fetchedPlans) {
  //           DateTime planDate = plan.date ?? DateTime.now();
  //           String key = _getDateKey(planDate);
  //           if (_plans[key] == null) _plans[key] = [];
  //           _plans[key]!.add(plan);
  //         }
  //       });
  //       widget.onPlansUpdate?.call(fetchedPlans);
  //     }
  //   } catch (e) {
  //     print('Error loading plans: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to load plans from server'), backgroundColor: Colors.red),
  //       );
  //     }
  //   }
  // }
  // ─────────────────────────────────────────────────────────────────────────

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void _notifyPlansUpdate() {
    List<Plan> allPlans = [];
    _plans.forEach((key, plansList) {
      allPlans.addAll(plansList);
    });
    widget.onPlansUpdate?.call(allPlans);
  }

  List<Plan> _getPlansForDay(DateTime day) {
    return _plans[_getDateKey(day)] ?? [];
  }

  // ── ADD: local only ───────────────────────────────────────────────────────
  void _addPlan(DateTime day, Plan plan) {
    plan.date = day;

    // TODO: re-enable when database is added
    // await Api.addPlan({
    //   'title': plan.title,
    //   'description': plan.description,
    //   'date': day.toIso8601String(),
    // });

    setState(() {
      String key = _getDateKey(day);
      if (_plans[key] == null) _plans[key] = [];
      _plans[key]!.add(plan);
    });

    _notifyPlansUpdate();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Plan added!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── DELETE: local only ────────────────────────────────────────────────────
  void _deletePlan(DateTime day, Plan plan, int index) {
    // TODO: re-enable when database is added
    // if (plan.id.isNotEmpty) {
    //   bool success = await Api.deletePlan(plan.id);
    //   if (!success) throw Exception('Failed to delete from server');
    // }

    setState(() {
      String key = _getDateKey(day);
      _plans[key]!.removeAt(index);
      if (_plans[key]!.isEmpty) _plans.remove(key);
    });

    _notifyPlansUpdate();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Plan deleted!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        _showPlanDialog(day);
      });
    }
  }

  // ── UPDATE: local only ────────────────────────────────────────────────────
  void _updatePlan(DateTime day, Plan oldPlan, Plan newPlan, int index) {
    // TODO: re-enable when database is added
    // if (newPlan.id.isNotEmpty) {
    //   bool success = await Api.updatePlan(newPlan.id, {
    //     'title': newPlan.title,
    //     'description': newPlan.description,
    //     'date': newPlan.date?.toIso8601String() ?? day.toIso8601String(),
    //   });
    //   if (!success) throw Exception('Failed to update on server');
    // }

    setState(() {
      String key = _getDateKey(day);
      _plans[key]![index] = newPlan;
    });

    _notifyPlansUpdate();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Plan updated!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
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
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
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
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deletePlan(selectedDay, plan, index);
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
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Plan'),
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
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
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
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

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
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          _addPlan(
                            selectedDay,
                            Plan(
                              id: '', // TODO: will be assigned by backend later
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              date: selectedDay,
                            ),
                          );
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
                      child: const Text('Add'),
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
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
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
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

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
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          Plan updatedPlan = Plan(
                            id: plan.id,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            date: plan.date ?? selectedDay,
                          );
                          _updatePlan(selectedDay, plan, updatedPlan, index);
                          Future.delayed(const Duration(milliseconds: 300), () {
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
                      child: const Text('Update'),
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
          Text(
            "My Agenda",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
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

                        // Disable adding plans to past days
                        final today = DateTime.now();
                        final isPastDay = selectedDay.isBefore(
                          DateTime(today.year, today.month, today.day),
                        );

                        if (isPastDay) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Can't add plans to past days.",
                              ),
                              backgroundColor: Colors.orange[700],
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }

                        _showPlanDialog(selectedDay);
                      },
                      eventLoader: (day) => _getPlansForDay(day),
                      onFormatChanged: (format) {
                        setState(() => _calendarFormat = format);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        markerSize: 7.0,
                        markersMaxCount: 1,
                        canMarkersOverflow: false,
                        // Past days greyed out
                        disabledTextStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white24
                              : Colors.black26,
                          fontSize: isCompact ? 12.sp : 14.sp,
                          //decoration: TextDecoration.lineThrough,
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
                        cellPadding: EdgeInsets.all(isCompact ? 4.w : 8.w),
                        cellMargin: EdgeInsets.all(isCompact ? 2.w : 4.w),
                      ),
                      // Disable interaction on past days
                      enabledDayPredicate: (day) {
                        final today = DateTime.now();
                        return !day.isBefore(
                          DateTime(today.year, today.month, today.day),
                        );
                      },
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
