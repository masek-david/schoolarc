import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/timeofday_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

/// Create new / edit a [LessonTimes] class
///
/// Returns a [LessonTimes] by popping
class EditPeriodDialog extends StatefulWidget {
  const EditPeriodDialog({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
    this.initialName,
    this.delete,
  });

  /// Default selected start time
  final TimeOfDay? initialStartTime;

  /// Default selected end time
  final TimeOfDay? initialEndTime;

  /// Default selected name of the [LessonTimes]
  final String? initialName;

  /// If provided, will show a button to delete this [LessonTimes]
  final void Function()? delete;

  @override
  State<EditPeriodDialog> createState() => _EditPeriodDialogState();
}

class _EditPeriodDialogState extends State<EditPeriodDialog> {
  late TimeOfDay? startTime = widget.initialStartTime;
  late TimeOfDay? endTime = widget.initialEndTime;
  late final nameController = TextEditingController(text: widget.initialName);

  /// This is the duration of the last period the user has added
  ///
  /// When the user is creating a new [LessonTimes], the [endTime] will
  /// be chosen automatically by adding [lastUsedPeriodDuration] to the [startTime]
  final Duration lastUsedPeriodDuration = Duration(
    minutes: settings.get(.timetablePeriodLastDuration),
  );

  LessonTimes? createPeriod() {
    if (startTime == null) return null;
    if (endTime == null) return null;

    return LessonTimes(
      startTime: startTime!,
      endTime: endTime!,
      name: nameController.text,
    );
  }

  void selectedStartTime(final TimeOfDay? selected) {
    if (selected != null) {
      endTime ??= TimeOfDay.fromDateTime(
        selected.toDateTime().add(lastUsedPeriodDuration),
      );
    }
    setState(() {
      startTime = selected;
    });
  }

  void save() {
    final periodDuration = endTime!
        .toDateTime()
        .difference(startTime!.toDateTime())
        .inMinutes;
    if (periodDuration > 0) {
      settings.save(.timetablePeriodLastDuration, periodDuration);
    }

    Navigator.pop(context, createPeriod());
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final period = createPeriod();

    return AlertDialog(
      actions: [
        if (widget.delete != null)
          DialogActionButton(
            isDestructiveAction: true,
            text: loc.delete,
            onPressed: () {
              widget.delete!();
              Navigator.pop(context);
            },
          ),
        DialogActionButton(
          text: loc.save,
          isDefaultAction: true,
          onPressed: period?.isValid == true ? save : null,
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            maxLength: timetablePeriodNameMaxLength,
            controller: nameController,
            style: googleSansFlex(
              width: 151,
              size: 28,
            ),
            textAlign: .center,
            decoration: InputDecoration(
              counterText: '',
              hintText: loc.name,
              fillColor: Colors.transparent,
            ),
          ),
          Text(
            textAlign: TextAlign.center,
            period?.toStringFormatted(context) ?? '',
            style: googleSansFlex(width: 25, size: 20),
          ),
          const SizedBox(height: 16),
          Text(loc.beginningTime, style: context.txt.titleMedium),
          M3ETextButton(
            size: .md,
            child: Text(startTime?.format(context) ?? loc.select),
            onPressed: () {
              showTimePicker(
                context: context,
                initialTime: startTime ?? const TimeOfDay(hour: 8, minute: 0),
              ).then(
                (value) => selectedStartTime(value),
              );
            },
          ),
          Text(loc.endingTime, style: context.txt.titleMedium),
          M3ETextButton(
            size: .md,
            child: Text(endTime?.format(context) ?? loc.select),
            onPressed: () {
              showTimePicker(
                context: context,
                initialTime: endTime ?? const TimeOfDay(hour: 8, minute: 45),
              ).then((value) {
                setState(() {
                  endTime = value;
                });
              });
            },
          ),
          if (period?.isValid == false)
            ErrorTile(
              error: StringException(context.loc.periodEndsBeforeStartError),
            ),
        ],
      ),
    );
  }
}
