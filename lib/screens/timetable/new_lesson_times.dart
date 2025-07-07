import 'package:flutter/material.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class NewLessonTimes extends StatefulWidget {
  const NewLessonTimes({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
    this.initialName,
    this.delete,
  });

  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final String? initialName;
  final void Function()? delete;

  @override
  State<NewLessonTimes> createState() => _NewLessonTimesState();
}

class _NewLessonTimesState extends State<NewLessonTimes> {
  late TimeOfDay? startTime = widget.initialStartTime;
  late TimeOfDay? endTime = widget.initialEndTime;
  late final nameController = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return AlertDialog(
      title: Text(loc.createNewTimes),
      actions: [
        if (widget.delete != null)
          OutlinedButton(
            onPressed: () {
              widget.delete!();
              Navigator.pop(context);
            },
            child: Text(loc.deleteThisLesson),
          ),
        FilledButton(
          onPressed: startTime != null && endTime != null
              ? () {
                  Navigator.pop(
                    context,
                    LessonTimes(
                      startTime: startTime!,
                      endTime: endTime!,
                      name: nameController.text,
                    ),
                  );
                }
              : null,
          child: Text(loc.save),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.beginningTime),
              TextButton(
                child: Text(startTime?.format(context) ?? loc.select),
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: startTime ?? TimeOfDay.now(),
                  ).then((value) {
                    setState(() {
                      startTime = value;
                    });
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.endingTime),
              TextButton(
                child: Text(endTime?.format(context) ?? loc.select),
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: endTime ?? TimeOfDay.now(),
                  ).then((value) {
                    setState(() {
                      endTime = value;
                    });
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
