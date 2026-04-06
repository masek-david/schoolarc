import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:table_calendar/table_calendar.dart';

class KeyboardDatePicker extends StatefulWidget {
  const KeyboardDatePicker({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<KeyboardDatePicker> createState() => _KeyboardDatePickerState();
}

class _KeyboardDatePickerState extends State<KeyboardDatePicker> {
  late DateTime date = widget.initialDate ?? DateTime.now();

  DateTime parseString(String text) {
    final date = DateTime.now();

    final split = text.split(RegExp(r'[., -/]'));
    final day = int.tryParse(split.elementAtOrNull(0) ?? '');
    final month = int.tryParse(split.elementAtOrNull(1) ?? '');
    final year = int.tryParse(split.elementAtOrNull(2) ?? '');

    return date.copyWith(day: day, month: month, year: year);
  }

  @override
  Widget build(BuildContext context) {
    final weekStartsOnMonday = settings.get(.weekStartsOnMonday);

    final color = context.col.primary;
    final onColor = context.col.onPrimary;
    final txt = googleSansFlex(
      size: 20,
      width: 121,
      weight: 500,
      roundness: 100,
      color: context.col.secondary,
    );

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            Text(
              DateFormat('d.M.y').format(date),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: DateFormat('d M y').format(date),
              ),
              onChanged: (value) {
                setState(() {
                  date = parseString(value);
                });
              },
              onEditingComplete: () {
                Navigator.pop(context, date);
              },
            ),
            Text(context.loc.useDateFormat),
            Text(context.loc.asDividerUse),
            TableCalendar(
              calendarStyle: .new(
                cellMargin: const EdgeInsets.all(2),
                todayDecoration: BoxDecoration(
                  shape: .circle,
                  border: Border.all(color: color, width: 2),
                ),
                selectedDecoration: BoxDecoration(
                  shape: .circle,
                  color: context.col.primary,
                ),
                todayTextStyle: txt,
                weekendTextStyle: txt,
                defaultTextStyle: txt,
                outsideTextStyle: txt,
                selectedTextStyle: txt.copyWith(
                  color: onColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              headerStyle: HeaderStyle(
                leftChevronPadding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                rightChevronPadding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                titleTextStyle: context.txt.titleLarge!,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: context.txt.labelLarge!,
                weekendStyle: context.txt.labelLarge!.copyWith(
                  color: context.col.onSurface.withAlpha(120),
                ),
              ),
              locale: context.locale.languageCode,
              daysOfWeekHeight: 20,
              availableCalendarFormats: const {.month: 'Month'},
              startingDayOfWeek: weekStartsOnMonday ? .monday : .sunday,
              focusedDay: date,
              selectedDayPredicate: (day) {
                return isSameDay(day, date);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  date = selectedDay;
                });
              },
              firstDay: DateTime(0),
              lastDay: DateTime(5000),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(context.loc.close),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, date);
                  },
                  child: Text(context.loc.ok),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
