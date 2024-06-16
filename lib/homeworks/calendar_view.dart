import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:school_manager/util/priority_model.dart';
import 'package:school_manager/homeworks/util/homework_tile.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({
    super.key,
    required this.hwByDate,
    required this.createNewHw,
    required this.changeCompletion,
    required this.deleteHw,
    required this.editHw,
  });

  final Map<DateTime, List<HomeworkDTO>> hwByDate;
  final Future<void> Function({DateTime? initialDate}) createNewHw;
  final Function changeCompletion;
  final Function deleteHw;
  final Function editHw;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final ValueNotifier<List<HomeworkDTO>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(getHwForDay(_selectedDay!));
  }

  List<HomeworkDTO> getHwForDay(DateTime day) {
    return widget.hwByDate[DateTime(day.year, day.month, day.day)] ?? [];
    // musi se shodovat pouze datum, ne cas
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.hwByDate.toString());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          HapticFeedback.lightImpact();
          await widget.createNewHw(initialDate: _selectedDay);
          _selectedEvents.value = getHwForDay(_selectedDay!);
        },
        enableFeedback: true,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000),
            lastDay: DateTime.utc(2100),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: _calendarFormat,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) => getHwForDay(day),
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine which day is currently selected.
              // If this returns true, then `day` will be marked as selected.
              
              // Using `isSameDay` is recommended to disregard
              // the time-part of compared DateTime objects.
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                // Call `setState()` when updating the selected day
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                _selectedEvents.value = getHwForDay(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SlidableAutoCloseBehavior(
                child: ValueListenableBuilder<List<HomeworkDTO>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length + 1,
                      itemBuilder: (context, index) {
                        if (index == value.length) {
                          return const SizedBox(height: 80);
                        }
                        HomeworkDTO hw = value[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: HomeworkTile(
                            text: hw.text,
                            subject: hw.subject,
                            completion: hw.completion,
                            priority: Priority(hw.priority, context),
                            onChangedCompletion: (completion) => widget.changeCompletion(hw.index),
                            onDelete: (context) => widget.deleteHw(hw.index),
                            onEdit: () => widget.editHw(hw.index),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
