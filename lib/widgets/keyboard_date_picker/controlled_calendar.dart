import 'package:flutter/material.dart';

class ControlledCalendar extends StatefulWidget {
  final DateTime selectedDate;

  final void Function(DateTime) onDateChanged;

  const ControlledCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<ControlledCalendar> createState() => _ControlledCalendarState();
}

class _ControlledCalendarState extends State<ControlledCalendar> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(covariant ControlledCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal selected date if parent changed it
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: _selectedDate,
      firstDate: DateTime(0),
      lastDate: DateTime(5000),
      onDateChanged: (newDate) {
        setState(() {
          _selectedDate = newDate;
        });
        widget.onDateChanged(newDate);
      },
    );
  }
}
